
variable "project_name" {
  description = "Project name used in AWSPro ALB resource names."
  type        = string
  default     = "ecs"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "prod"
}

variable "vpc_id" {
  description = "VPC ID where the ALB and ECS target group are created."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs across at least two Availability Zones."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_ids) >= 2
    error_message = "Provide at least two public subnet IDs for ALB high availability."
  }
}

variable "alb_security_group_id" {
  description = "Security group ID assigned to the ALB."
  type        = string
}

#variable "acm_certificate_arn" {
#  description = "ARN of an issued ACM certificate in the same Region as the ALB."
#  type        = string
#}

variable "health_check_path" {
  description = "HTTP path used by the ALB target group health check."
  type        = string
  default     = "/"
}

variable "health_check_matcher" {
  description = "HTTP status codes accepted as healthy."
  type        = string
  default     = "200-399"
}

variable "enable_deletion_protection" {
  description = "Enable ALB deletion protection."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags applied to supported ALB resources."
  type        = map(string)
  default     = {}
}
