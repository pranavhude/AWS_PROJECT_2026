
variable "identifier" {
  description = "Unique RDS DB instance identifier"
  type        = string
  default     = "awspro-mysql-dev"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "vpc_id" {
  description = "ID of the existing Dev VPC"
  type        = string
}

variable "private_db_subnet_ids" {
  description = "Private DB subnet IDs in at least two Availability Zones"
  type        = list(string)

  validation {
    condition     = length(var.private_db_subnet_ids) >= 2
    error_message = "Provide at least two private DB subnets."
  }
}

variable "ecs_security_group_id" {
  description = "Security group ID attached to ECS application instances"
  type        = string
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "awsproapp"
}

variable "master_username" {
  description = "RDS master username"
  type        = string
  default     = "awsproadmin"
}

variable "engine_version" {
  description = "Supported MySQL engine version in the selected AWS region"
  type        = string
  default     = "8.0"
}

variable "instance_class" {
  description = "RDS DB instance class"
  type        = string
  default     = "db.t3.small"
}

variable "allocated_storage" {
  description = "Initial allocated storage in GiB"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum autoscaled storage in GiB"
  type        = number
  default     = 100
}

variable "final_snapshot_identifier" {
  description = "Unique identifier for the final deletion snapshot"
  type        = string
  default     = "awspro-mysql-dev-final-snapshot"
}
