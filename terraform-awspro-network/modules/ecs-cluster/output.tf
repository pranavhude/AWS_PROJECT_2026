
output "cluster_id" {
  description = "ECS cluster ID"
  value       = aws_ecs_cluster.awspro_ecs_cluster.id
}

output "cluster_arn" {
  description = "ECS cluster ARN"
  value       = aws_ecs_cluster.awspro_ecs_cluster.arn
}

output "cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.awspro_ecs_cluster.name
}
