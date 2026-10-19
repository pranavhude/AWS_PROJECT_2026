
# --------------------------------------------------
# VPC OUTPUTS
# --------------------------------------------------

output "awspro_vpc_id" {
  description = "ID of the AWSPro VPC."
  value       = aws_vpc.awspro_vpc.id
}

output "awspro_vpc_arn" {
  description = "ARN of the AWSPro VPC."
  value       = aws_vpc.awspro_vpc.arn
}

output "awspro_vpc_cidr" {
  description = "IPv4 CIDR block of the VPC."
  value       = aws_vpc.awspro_vpc.cidr_block
}

# --------------------------------------------------
# AVAILABILITY ZONES
# --------------------------------------------------

output "awspro_availability_zones" {
  description = "Availability Zones used by the network."
  value       = local.awspro_azs
}

# --------------------------------------------------
# SUBNET OUTPUTS
# --------------------------------------------------

output "awspro_public_subnet_ids" {
  description = "Public subnet IDs for internet-facing load balancers."
  value       = aws_subnet.awspro_public[*].id
}

output "awspro_private_subnet_ids" {
  description = "Private subnet IDs for ECS, EKS, and EC2 workloads."
  value       = aws_subnet.awspro_private[*].id
}

output "awspro_database_subnet_ids" {
  description = "Optional isolated database subnet IDs."
  value       = aws_subnet.awspro_database[*].id
}

# --------------------------------------------------
# ROUTE TABLE OUTPUTS
# --------------------------------------------------

output "awspro_public_route_table_id" {
  description = "ID of the public route table."
  value       = aws_route_table.awspro_public.id
}

output "awspro_private_route_table_ids" {
  description = "IDs of the private application route tables."
  value       = aws_route_table.awspro_private[*].id
}

output "awspro_database_route_table_ids" {
  description = "Database route table IDs, or an empty list if not configured."
  value       = aws_route_table.awspro_database[*].id
}

# --------------------------------------------------
# INTERNET GATEWAY OUTPUT
# --------------------------------------------------

output "awspro_internet_gateway_id" {
  description = "ID of the Internet Gateway."
  value       = aws_internet_gateway.awspro_igw.id
}

# --------------------------------------------------
# NAT GATEWAY OUTPUTS
# --------------------------------------------------

output "awspro_nat_gateway_ids" {
  description = "NAT Gateway IDs, or an empty list if NAT is disabled."
  value       = aws_nat_gateway.awspro_nat[*].id
}
