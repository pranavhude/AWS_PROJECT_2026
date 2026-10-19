variable "aws_region" {
  description = "AWS region where the Terraform state bucket is created."
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Short project identifier used in resource names."
  type        = string
  default     = "ecs-infrastructure"

  validation {
    condition = (
      length(var.project_name) >= 3 &&
      length(var.project_name) <= 30 &&
      can(regex("^[a-z0-9-]+$", var.project_name))
    )
    error_message = "Use 3-30 lowercase letters, numbers, or hyphens."
  }
}

variable "kms_deletion_window_days" {
  description = "Waiting period before a scheduled KMS key deletion."
  type        = number
  default     = 30

  validation {
    condition = (
      var.kms_deletion_window_days >= 7 &&
      var.kms_deletion_window_days <= 30
    )
    error_message = "KMS deletion window must be between 7 and 30 days."
  }
}

variable "common_tags" {
  description = "Additional tags for bootstrap resources."
  type        = map(string)
  default     = {}
}