
output "task_definition_arn" {
  description = "ECS task definition ARN"
  value       = aws_ecs_task_definition.awspro_ecs_task_definition.arn
}

output "task_definition_family" {
  description = "ECS task definition family"
  value       = aws_ecs_task_definition.awspro_ecs_task_definition.family
}

output "task_definition_revision" {
  description = "Registered task definition revision"
  value       = aws_ecs_task_definition.awspro_ecs_task_definition.revision
}
