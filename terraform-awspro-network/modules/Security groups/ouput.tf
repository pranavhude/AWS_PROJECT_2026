
output "awspro_nlb_security_group_id" {
  description = "Security group ID for the AWSPro NLB."
  value       = aws_security_group.awspro_nlb_sg.id
}

output "awspro_alb_security_group_id" {
  description = "Security group ID for the AWSPro ALB."
  value       = aws_security_group.awspro_alb_sg.id
}

output "awspro_ecs_security_group_id" {
  description = "Security group ID for AWSPro ECS EC2 instances."
  value       = aws_security_group.awspro_ecs_sg.id
}

output "awspro_db_security_group_id" {
  description = "Security group ID for Aurora PostgreSQL in this Region."
  value       = aws_security_group.awspro_db_sg.id
}

output "awspro_bastion_security_group_id" {
  description = "Optional bastion security group ID, or null when disabled."
  value       = try(aws_security_group.awspro_bastion_sg[0].id, null)
}

output "awspro_vpce_security_group_id" {
  description = "Optional interface VPC endpoint security group ID, or null when disabled."
  value       = try(aws_security_group.awspro_vpce_sg[0].id, null)
}
