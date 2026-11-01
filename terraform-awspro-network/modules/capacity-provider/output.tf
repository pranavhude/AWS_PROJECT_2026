
output "capacity_provider_name" {
  description = "ECS capacity provider name"
  value       = aws_ecs_capacity_provider.awspro_ecs_capacity_provider.name
}

output "cluster_name" {
  description = "ECS cluster associated with the capacity provider"
  value       = aws_ecs_cluster_capacity_providers.awspro_cluster_capacity_providers.cluster_name
}
