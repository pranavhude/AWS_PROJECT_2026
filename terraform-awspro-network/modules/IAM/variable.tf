
variable "project_name" {
  description = "Project name used in AWSPro IAM resource names."
  type        = string
  default     = "ecs"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "prod"
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster that EC2 instances will join."
  type        = string
}

variable "ecr_repository_arns" {
  description = "ECR repository ARNs from which ECS tasks pull images."
  type        = list(string)

  validation {
    condition     = length(var.ecr_repository_arns) > 0
    error_message = "Provide at least one ECR repository ARN."
  }
}

variable "cloudwatch_log_group_arn" {
  description = "ARN of the existing CloudWatch log group, without a trailing :*."
  type        = string
}

variable "secret_arns" {
  description = "Optional Secrets Manager secret ARNs required by ECS tasks at startup."
  type        = list(string)
  default     = []
}

variable "kms_key_arn" {
  description = "Optional customer-managed KMS key ARN for encrypted application secrets."
  type        = string
  default     = ""
}

variable "enable_ssm" {
  description = "Grant the EC2 instance role the permissions needed for SSM Session Manager."
  type        = bool
  default     = true
}

variable "task_policy_statements" {
  description = "Least-privilege application permissions for the ECS task role."
  type = list(object({
    sid       = optional(string)
    actions   = list(string)
    resources = list(string)
  }))
  default = []
}

variable "tags" {
  description = "Additional tags for IAM resources that support tags."
  type        = map(string)
  default     = {}
}
