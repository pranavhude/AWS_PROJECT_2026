
output "log_group_name" {
  description = "CloudWatch log group for ECS containers"
  value       = aws_cloudwatch_log_group.awspro_ecs_logs.name
}

output "ecs_cpu_alarm_name" {
  description = "ECS CPU alarm name"
  value       = aws_cloudwatch_metric_alarm.awspro_ecs_cpu_high.alarm_name
}

output "asg_capacity_alarm_name" {
  description = "ASG capacity alarm name"
  value       = aws_cloudwatch_metric_alarm.awspro_asg_capacity_low.alarm_name
}
