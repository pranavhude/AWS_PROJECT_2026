
variable "cluster_name" {
  description = "Existing ECS cluster name"
  type        = string
}

variable "asg_name" {
  description = "Existing ECS Auto Scaling Group name"
  type        = string
}

variable "log_retention_days" {
  description = "CloudWatch log retention period"
  type        = number
  default     = 30
}

variable "cpu_threshold" {
  description = "ECS cluster CPU alarm threshold percentage"
  type        = number
  default     = 80
}

variable "min_in_service_instances" {
  description = "Minimum expected in-service EC2 instances"
  type        = number
  default     = 2
}

variable "alarm_actions" {
  description = "Optional SNS topic ARNs for alarm notifications"
  type        = list(string)
  default     = []
}
