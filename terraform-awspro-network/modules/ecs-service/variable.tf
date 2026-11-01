
variable "cluster_arn" {
  description = "ECS cluster ARN"
  type        = string
}

variable "task_definition_arn" {
  description = "ECS task definition ARN"
  type        = string
}

variable "desired_count" {
  description = "Initial number of application tasks"
  type        = number
  default     = 2
}

variable "target_group_arn" {
  description = "ALB target group ARN"
  type        = string
}

variable "container_name" {
  description = "Container name in the task definition"
  type        = string
  default     = "awspro-app"
}

variable "container_port" {
  description = "Application container port"
  type        = number
  default     = 80
}
