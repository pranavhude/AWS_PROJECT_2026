
variable "project_name" {
  description = "Project name used in AWSPro ECR resource naming."
  type        = string
  default     = "ecs"
}

variable "environment" {
  description = "Deployment environment, such as dev, uat, staging, or prod."
  type        = string
  default     = "prod"
}

variable "repository_name" {
  description = "ECR repository name. Must use lowercase letters, numbers, hyphens, underscores, or slashes."
  type        = string
  default     = "application"

  validation {
    condition = (
      length(var.repository_name) >= 2 &&
      length(var.repository_name) <= 256 &&
      can(regex("^[a-z0-9]+([._/-][a-z0-9]+)*$", var.repository_name))
    )
    error_message = "Repository name must contain valid lowercase ECR name characters."
  }
}

variable "image_tag_mutability" {
  description = "Image tag policy: MUTABLE or IMMUTABLE."
  type        = string
  default     = "IMMUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "image_tag_mutability must be MUTABLE or IMMUTABLE."
  }
}

variable "scan_on_push" {
  description = "Enable image vulnerability scanning on image push."
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "Optional customer-managed KMS key ARN. Empty uses ECR AES-256 encryption."
  type        = string
  default     = ""
}

variable "images_to_retain" {
  description = "Number of recent tagged images to retain."
  type        = number
  default     = 30

  validation {
    condition     = var.images_to_retain >= 1
    error_message = "images_to_retain must be at least 1."
  }
}

variable "untagged_image_retention_days" {
  description = "Days to retain untagged images before expiration."
  type        = number
  default     = 7

  validation {
    condition     = var.untagged_image_retention_days >= 1
    error_message = "untagged_image_retention_days must be at least 1."
  }
}

variable "tags" {
  description = "Additional tags for ECR resources."
  type        = map(string)
  default     = {}
}
