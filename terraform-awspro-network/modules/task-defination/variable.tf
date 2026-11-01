
variable "task_family" {
  description = "ECS task definition family name"
  type        = string
  default     = "awspro-ecs-task-dev"
}

variable "container_name" {
  description = "Application container name"
  type        = string
  default     = "awspro-app"
}

variable "container_image" {
  description = "Full application image URI in ECR"
  type        = string
}

variable "container_port" {
  description = "Application container port"
  type        = number
  default     = 80
}

variable "task_cpu" {
  description = "Task CPU units"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Task memory in MiB"
  type        = number
  default     = 512
}

variable "execution_role_arn" {
  description = "ECS task execution IAM role ARN"
  type        = string
}

variable "task_role_arn" {
  description = "Optional IAM role used by application code"
  type        = string
  default     = ""
}

variable "db_secret_arn" {
  description = "Secrets Manager secret ARN containing username and password JSON keys"
  type        = string
}

variable "db_host" {
  description = "Private MySQL endpoint hostname"
  type        = string
}

variable "db_port" {
  description = "MySQL database port"
  type        = number
  default     = 3306
}

variable "db_name" {
  description = "Application database name"
  type        = string
}

variable "log_group_name" {
  description = "Existing CloudWatch log group name"
  type        = string
}

variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "eu-west-1"
}
