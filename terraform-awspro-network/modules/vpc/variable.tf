
variable "project_name" {
  description = "Project name used in resource naming."
  type        = string
  default     = "ecs-app"
}

variable "environment" {
  description = "Environment name: dev, qa, staging, or prod."
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "availability_zone_names" {
  description = "Optional list of exactly two Availability Zones."
  type        = list(string)
  default     = []
}

variable "public_subnet_cidrs" {
  description = "CIDRs for two public subnets."
  type        = list(string)
  default     = [
    "10.20.1.0/24",
    "10.20.2.0/24"
  ]

  validation {
    condition     = length(var.public_subnet_cidrs) == 2
    error_message = "Provide exactly two public subnet CIDRs."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDRs for two private application subnets."
  type        = list(string)
  default     = [
    "10.20.11.0/24",
    "10.20.12.0/24"
  ]

  validation {
    condition     = length(var.private_subnet_cidrs) == 2
    error_message = "Provide exactly two private subnet CIDRs."
  }
}

variable "database_subnet_cidrs" {
  description = "Optional isolated database subnet CIDRs."
  type        = list(string)
  default     = []

  validation {
    condition = (
      length(var.database_subnet_cidrs) == 0 ||
      length(var.database_subnet_cidrs) == 2
    )
    error_message = "Provide zero or exactly two database subnet CIDRs."
  }
}

variable "enable_nat_gateway" {
  description = "Whether to create NAT Gateway resources."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use one NAT Gateway instead of one per AZ."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags for all supported network resources."
  type        = map(string)
  default     = {}
}
