
variable "min_size" {
  description = "Minimum number of EC2 instances"
  type        = number
  default     = 2
}

variable "desired_capacity" {
  description = "Initial desired number of EC2 instances"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of EC2 instances"
  type        = number
  default     = 4
}

variable "private_subnet_ids" {
  description = "Private subnet IDs across two Availability Zones"
  type        = list(string)
}

variable "launch_template_id" {
  description = "Launch template ID"
  type        = string
}

variable "launch_template_version" {
  description = "Launch template version"
  type        = number
}
