
variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = "awspro-ecs-cluster-dev"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}
