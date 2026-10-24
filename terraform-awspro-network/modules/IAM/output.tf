
output "awspro_ecs_instance_role_arn" {
  description = "ARN of the AWSPro ECS EC2 instance role."
  value       = aws_iam_role.awspro_ecs_ec2_instance_role.arn
}

output "awspro_ecs_instance_role_name" {
  description = "Name of the AWSPro ECS EC2 instance role."
  value       = aws_iam_role.awspro_ec2_instance_role.name
}

output "awspro_ecs_instance_profile_name" {
  description = "Instance profile name for the Launch Template."
  value       = aws_iam_instance_profile.awspro_ecs_instance_profile.name
}

output "awspro_ecs_instance_profile_arn" {
  description = "Instance profile ARN for the Launch Template."
  value       = aws_iam_instance_profile.awspro_ecs_instance_profile.arn
}

output "awspro_ecs_task_execution_role_arn" {
  description = "ARN to use as execution_role_arn in the ECS task definition."
  value       = aws_iam_role.awspro_ecs_task_execution_role.arn
}

output "awspro_ecs_task_role_arn" {
  description = "ARN to use as task_role_arn in the ECS task definition."
  value       = aws_iam_role.awspro_ecs_task_role.arn
}
