
output "awspro_ecr_repository_name" {
  description = "Name of the AWSPro ECR repository."
  value       = aws_ecr_repository.awspro_ecr_repository.name
}

output "awspro_ecr_repository_arn" {
  description = "ARN of the AWSPro ECR repository for IAM policies."
  value       = aws_ecr_repository.awspro_ecr_repository.arn
}

output "awspro_ecr_repository_url" {
  description = "Repository URL used to tag and push container images."
  value       = aws_ecr_repository.awspro_ecr_repository.repository_url
}

output "awspro_ecr_registry_id" {
  description = "AWS account ID that owns the ECR repository."
  value       = aws_ecr_repository.awspro_ecr_repository.registry_id
}
