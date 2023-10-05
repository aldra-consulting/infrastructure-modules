output "ecs_cluster_arn" {
  description = "ARN that identifies the ECS cluster"
  value       = module.ecs_cluster.arn
}

output "ecs_cluster_id" {
  description = "ID that identifies the ECS cluster"
  value       = module.ecs_cluster.id
}

output "ecs_cluster_name" {
  description = "Name that identifies the ECS cluster"
  value       = module.ecs_cluster.name
}

output "ecs_cluster_capacity_providers" {
  description = "Map of cluster capacity providers attributes"
  value       = module.ecs_cluster.cluster_capacity_providers
}

output "service_id" {
  description = "ARN that identifies the service"
  value       = { for service in local.services : service.name => module.ecs_service[service.name].id }
}

output "service_name" {
  description = "Name of the service"
  value       = { for service in local.services : service.name => module.ecs_service[service.name].name }
}

output "load_balancer_id" {
  description = "The ID and ARN of the load balancer"
  value       = { for service in local.services : service.name => module.load_balancer[service.name].lb_id }
}

output "load_balancer_arn" {
  description = "The ID and ARN of the load balancer"
  value       = { for service in local.services : service.name => module.load_balancer[service.name].lb_arn }
}

output "load_balancer_dns_name" {
  description = "The DNS name of the load balancer"
  value       = { for service in local.services : service.name => module.load_balancer[service.name].lb_dns_name }
}
