
variable "project_name" {
  description = "Project name used in AWSPro security group names."
  type        = string
  default     = "ecs"
}

variable "environment" {
  description = "Deployment environment, such as dev, uat, or prod."
  type        = string
  default     = "prod"
}

variable "vpc_id" {
  description = "VPC ID in the current AWS Region."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block, reserved for additional network rules if needed."
  type        = string
  default     = "10.20.0.0/16"
}

variable "allowed_client_cidrs" {
  description = "Client CIDRs allowed to reach the internet-facing NLB on TCP 443."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ecs_dynamic_host_port_min" {
  description = "Minimum ECS dynamic host-port range for bridge networking."
  type        = number
  default     = 32768
}

variable "ecs_dynamic_host_port_max" {
  description = "Maximum ECS dynamic host-port range for bridge networking."
  type        = number
  default     = 61000

  validation {
    condition = (
      var.ecs_dynamic_host_port_max >=
      var.ecs_dynamic_host_port_min
    )
    error_message = "The maximum dynamic host port must be greater than or equal to the minimum."
  }
}

variable "create_bastion_sg" {
  description = "Whether to create an optional bastion security group."
  type        = bool
  default     = false
}

variable "bastion_admin_cidrs" {
  description = "Approved administrator CIDRs for optional bastion SSH access."
  type        = list(string)
  default     = []
}

variable "create_vpce_sg" {
  description = "Whether to create an optional interface VPC endpoint security group."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags applied to all security groups."
  type        = map(string)
  default     = {}
}
