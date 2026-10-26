
output "asg_name" {
  value = aws_autoscaling_group.awspro_ecs_asg.name
}

output "asg_arn" {
  value = aws_autoscaling_group.awspro_ecs_asg.arn
}
