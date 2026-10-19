output "terraform_state_bucket_name" {
  description = "S3 bucket used for Terraform remote state."
  value       = aws_s3_bucket.terraform_state.bucket
}

output "terraform_state_bucket_arn" {
  description = "ARN of the Terraform state bucket."
  value       = aws_s3_bucket.terraform_state.arn
}

output "terraform_state_kms_key_arn" {
  description = "KMS key ARN used to encrypt Terraform state."
  value       = aws_kms_key.terraform_state.arn
}

output "terraform_state_region" {
  description = "AWS region containing the state bucket."
  value       = var.aws_region
}