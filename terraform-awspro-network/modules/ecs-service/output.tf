
output "service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.awspro_ecs_service.name
}

output "service_arn" {
  description = "ECS service ARN"
  value       = aws_ecs_service.awspro_ecs_service.id
}
