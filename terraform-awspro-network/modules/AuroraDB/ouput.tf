
output "db_instance_id" {
  description = "RDS DB instance identifier"
  value       = aws_db_instance.awspro_mysql.id
}

output "db_endpoint" {
  description = "Private RDS endpoint hostname"
  value       = aws_db_instance.awspro_mysql.address
}

output "db_port" {
  description = "MySQL port"
  value       = aws_db_instance.awspro_mysql.port
}

output "db_security_group_id" {
  description = "RDS security group ID"
  value       = aws_security_group.awspro_mysql_sg.id
}

output "master_secret_arn" {
  description = "ARN of the AWS-managed master credentials secret"
  value       = aws_db_instance.awspro_mysql.master_user_secret[0].secret_arn
}
