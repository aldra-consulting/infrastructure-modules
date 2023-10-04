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
