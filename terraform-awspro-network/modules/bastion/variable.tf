
variable "vpc_id" {
  description = "ID of the existing Dev VPC"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID with a route to the Internet Gateway"
  type        = string
}

variable "allowed_ssh_cidrs" {
  description = "Approved administrator public IP CIDRs, for example 203.0.113.10/32"
  type        = list(string)

  validation {
    condition = (
      length(var.allowed_ssh_cidrs) > 0 &&
      alltrue([
        for cidr in var.allowed_ssh_cidrs :
        can(cidrhost(cidr, 0)) && cidr != "0.0.0.0/0"
      ])
    )
    error_message = "Provide valid, restricted administrator CIDRs. Do not allow SSH from 0.0.0.0/0."
  }
}

variable "instance_type" {
  description = "Bastion EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Existing EC2 key pair name; null when using SSM only"
  type        = string
  default     = null
  nullable    = true
}
