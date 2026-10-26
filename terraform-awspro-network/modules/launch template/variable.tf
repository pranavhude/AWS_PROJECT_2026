
variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "instance_profile_name" {
  description = "Existing EC2 IAM instance profile with ECS and SSM permissions"
  type        = string
}

variable "security_group_ids" {
  description = "Existing ECS EC2 security group IDs"
  type        = list(string)
}

variable "ecs_cluster_name" {
  description = "Exact name of the existing ECS cluster"
  type        = string
}
