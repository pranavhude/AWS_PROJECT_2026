
variable "project_name" {
  description = "Project name used in AWSPro secret names."
  type        = string
  default     = "ecs"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "prod"
}

variable "secret_names" {
  description = "Map of logical secret keys to secret name suffixes."
  type        = map(string)

  default = {
    database = "database"
    app      = "application"
  }

  validation {
    condition     = length(var.secret_names) > 0
    error_message = "Provide at least one secret name."
  }
}

variable "kms_key_arn" {
  description = "Optional customer-managed KMS key ARN in this Region. Empty uses Secrets Manager AWS-managed encryption."
  type        = string
  default     = ""
}

variable "recovery_window_in_days" {
  description = "Days before deleted secrets are permanently removed. Use 7-30 for production."
  type        = number
  default     = 30

  validation {
    condition = (
      var.recovery_window_in_days == 0 ||
      (
        var.recovery_window_in_days >= 7 &&
        var.recovery_window_in_days <= 30
      )
    )
    error_message = "Recovery window must be 0 or between 7 and 30 days."
  }
}

variable "tags" {
  description = "Additional tags for supported Secrets Manager resources."
  type        = map(string)
  default     = {}
}
