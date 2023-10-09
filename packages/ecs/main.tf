# ------------------------------------------------------------------------------
# Module setup
# ------------------------------------------------------------------------------

terraform {
  backend "s3" {}
}

locals {
  namespace = var.namespace
  tags      = var.tags
  vpc       = var.vpc
  services  = var.services
}

provider "aws" {}

# ------------------------------------------------------------------------------
# Module configuration
# ------------------------------------------------------------------------------

module "ecs_cluster" {
  source = "terraform-aws-modules/ecs/aws//modules/cluster"

  cluster_name = "${local.namespace}-ecs-cluster"

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 100
      }
    }
  }

  tags = local.tags
}

data "aws_ecr_repository" "this" {
  for_each = { for service in local.services : service.name => service }

  name = "${local.namespace}-${each.key}"
}

data "aws_ecr_image" "this" {
  for_each = { for service in local.services : service.name => service }

  repository_name = data.aws_ecr_repository.this[each.key].name
  image_tag       = "latest"
}

module "load_balancer" {
  for_each = { for service in local.services : service.name => service }

  source = "terraform-aws-modules/alb/aws"

  name = each.key

  load_balancer_type = "network"

  internal = true

  vpc_id  = local.vpc.id
  subnets = local.vpc.private_subnets

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "TCP"
      target_group_index = 0
    }
  ]

  target_groups = [
    {
      name             = each.key
      backend_protocol = "TCP"
      backend_port     = each.value.port
      target_type      = "ip"
      health_check = {
        enabled             = true
        interval            = 10
        path                = "/health"
        port                = each.value.port
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 10
        protocol            = "HTTP"
        matcher             = "200"
      }
    },
  ]

  tags = local.tags
}

module "ecs_service" {
  for_each = { for service in local.services : service.name => service }

  source = "terraform-aws-modules/ecs/aws//modules/service"

  name        = each.key
  cluster_arn = module.ecs_cluster.arn

  cpu    = 512
  memory = 1024

  container_definitions = {
    (each.key) = {
      cpu       = 512
      memory    = 1024
      essential = true
      image     = "${data.aws_ecr_repository.this[each.key].repository_url}@${data.aws_ecr_image.this[each.key].id}"
      port_mappings = [
        {
          name          = each.key
          containerPort = each.value.port
          hostPort      = each.value.port
          protocol      = "tcp"
        }
      ]
      environment = [
        for key, value in each.value.environment :
        {
          name  = key
          value = value
        }
      ]
    }
  }

  load_balancer = {
    service = {
      target_group_arn = element(module.load_balancer[each.key].target_group_arns, 0)
      container_name   = each.key
      container_port   = each.value.port
    }
  }

  subnet_ids = local.vpc.private_subnets

  security_group_rules = {
    ingress_nlb = {
      type        = "ingress"
      from_port   = each.value.port
      to_port     = each.value.port
      protocol    = "tcp"
      cidr_blocks = local.vpc.private_subnets_cidr_blocks
      description = "Service port"
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = local.vpc.private_subnets_cidr_blocks
    }
  }

  tags = local.tags
}
