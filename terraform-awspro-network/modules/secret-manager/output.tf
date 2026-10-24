
output "awspro_secret_arns" {
  description = "Map of logical secret keys to Secrets Manager ARNs."
  value = {
    for key, secret in aws_secretsmanager_secret.awspro_secret :
    key => secret.arn
  }
}

output "awspro_secret_names" {
  description = "Map of logical secret keys to Secrets Manager names."
  value = {
    for key, secret in aws_secretsmanager_secret.awspro_secret :
    key => secret.name
  }
}

output "awspro_database_secret_arn" {
  description = "ARN of the database secret, if configured."
  value       = try(aws_secretsmanager_secret.awspro_secret["database"].arn, null)
}

output "awspro_application_secret_arn" {
  description = "ARN of the application secret, if configured."
  value       = try(aws_secretsmanager_secret.awspro_secret["app"].arn, null)
}
