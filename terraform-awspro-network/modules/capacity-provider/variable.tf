
variable "cluster_name" {
  description = "Name of the existing ECS cluster"
  type        = string
}

variable "asg_arn" {
  description = "ARN of the existing ECS Auto Scaling Group"
  type        = string
}
