
variable "project_name" {
  description = "Project name used in AWSPro NLB resource names."
  type        = string
  default     = "ecs"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "prod"
}

variable "vpc_id" {
  description = "VPC ID containing the NLB and ALB."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs in at least two Availability Zones."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_ids) >= 2
    error_message = "Provide at least two public subnet IDs for high availability."
  }
}

variable "nlb_security_group_id" {
  description = "Security group to associate with the NLB at creation."
  type        = string
}

variable "alb_arn" {
  description = "ARN of the existing ALB registered as the NLB target."
  type        = string
}

variable "enable_deletion_protection" {
  description = "Enable NLB deletion protection in production."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags for supported NLB resources."
  type        = map(string)
  default     = {}
}
