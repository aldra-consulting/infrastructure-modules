# ------------------------------------------------------------------------------
# Module setup
# ------------------------------------------------------------------------------

terraform {
  backend "s3" {}
}

locals {
  namespace = var.namespace
  tags      = var.tags
  cidr      = var.cidr
  azs       = slice(data.aws_availability_zones.this.names, 0, 3)
}

provider "aws" {}

# ------------------------------------------------------------------------------
# Module configuration
# ------------------------------------------------------------------------------

data "aws_availability_zones" "this" {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${local.namespace}-vpc"

  azs = local.azs

  cidr = local.cidr

  public_subnets   = [for k, v in local.azs : cidrsubnet(local.cidr, 8, k)]
  private_subnets  = [for k, v in local.azs : cidrsubnet(local.cidr, 8, k + 4)]
  database_subnets = [for k, v in local.azs : cidrsubnet(local.cidr, 8, k + 8)]

  tags = local.tags
}
