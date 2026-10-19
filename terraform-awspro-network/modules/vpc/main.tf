
# --------------------------------------------------
# DATA SOURCE: AVAILABLE AVAILABILITY ZONES
# --------------------------------------------------

data "aws_availability_zones" "awspro_available" {
  state = "available"
}

# --------------------------------------------------
# LOCALS
# --------------------------------------------------

locals {
  awspro_azs = length(var.availability_zone_names) == 2 ? (
    var.availability_zone_names
  ) : slice(
    data.aws_availability_zones.awspro_available.names,
    0,
    2
  )

  awspro_name_prefix = "awspro-${var.project_name}-${var.environment}"

  awspro_common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.tags
  )

  awspro_nat_count = var.enable_nat_gateway ? (
    var.single_nat_gateway ? 1 : 2
  ) : 0
}

# --------------------------------------------------
# VPC
# --------------------------------------------------

resource "aws_vpc" "awspro_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.awspro_common_tags, {
    Name = "${local.awspro_name_prefix}-vpc"
  })
}

# --------------------------------------------------
# INTERNET GATEWAY
# --------------------------------------------------

resource "aws_internet_gateway" "awspro_igw" {
  vpc_id = aws_vpc.awspro_vpc.id

  tags = merge(local.awspro_common_tags, {
    Name = "${local.awspro_name_prefix}-igw"
  })
}

# --------------------------------------------------
# PUBLIC SUBNETS
# --------------------------------------------------

resource "aws_subnet" "awspro_public" {
  count = 2

  vpc_id                  = aws_vpc.awspro_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = local.awspro_azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.awspro_common_tags, {
    Name = "${local.awspro_name_prefix}-public-${count.index + 1}"
    Tier = "Public"
  })
}

# --------------------------------------------------
# PRIVATE APPLICATION SUBNETS
# --------------------------------------------------

resource "aws_subnet" "awspro_private" {
  count = 2

  vpc_id                  = aws_vpc.awspro_vpc.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = local.awspro_azs[count.index]
  map_public_ip_on_launch = false

  tags = merge(local.awspro_common_tags, {
    Name = "${local.awspro_name_prefix}-private-${count.index + 1}"
    Tier = "Private"
  })
}

# --------------------------------------------------
# OPTIONAL DATABASE SUBNETS
# --------------------------------------------------

resource "aws_subnet" "awspro_database" {
  count = length(var.database_subnet_cidrs)

  vpc_id                  = aws_vpc.awspro_vpc.id
  cidr_block              = var.database_subnet_cidrs[count.index]
  availability_zone       = local.awspro_azs[count.index]
  map_public_ip_on_launch = false

  tags = merge(local.awspro_common_tags, {
    Name = "${local.awspro_name_prefix}-database-${count.index + 1}"
    Tier = "Database"
  })
}

# --------------------------------------------------
# PUBLIC ROUTE TABLE
# --------------------------------------------------

resource "aws_route_table" "awspro_public" {
  vpc_id = aws_vpc.awspro_vpc.id

  tags = merge(local.awspro_common_tags, {
    Name = "${local.awspro_name_prefix}-public-rt"
  })
}

resource "aws_route" "awspro_public_default" {
  route_table_id         = aws_route_table.awspro_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.awspro_igw.id
}

resource "aws_route_table_association" "awspro_public" {
  count = 2

  subnet_id      = aws_subnet.awspro_public[count.index].id
  route_table_id = aws_route_table.awspro_public.id
}

# --------------------------------------------------
# NAT ELASTIC IP ADDRESSES
# --------------------------------------------------

resource "aws_eip" "awspro_nat" {
  count  = local.awspro_nat_count
  domain = "vpc"

  tags = merge(local.awspro_common_tags, {
    Name = "${local.awspro_name_prefix}-nat-eip-${count.index + 1}"
  })

  depends_on = [aws_internet_gateway.awspro_igw]
}

# --------------------------------------------------
# NAT GATEWAYS
# --------------------------------------------------

resource "aws_nat_gateway" "awspro_nat" {
  count = local.awspro_nat_count

  allocation_id = aws_eip.awspro_nat[count.index].id
  subnet_id     = aws_subnet.awspro_public[count.index].id

  tags = merge(local.awspro_common_tags, {
    Name = "${local.awspro_name_prefix}-nat-${count.index + 1}"
  })

  depends_on = [aws_internet_gateway.awspro_igw]
}

# --------------------------------------------------
# PRIVATE ROUTE TABLES
# --------------------------------------------------

resource "aws_route_table" "awspro_private" {
  count = 2

  vpc_id = aws_vpc.awspro_vpc.id

  tags = merge(local.awspro_common_tags, {
    Name = "${local.awspro_name_prefix}-private-rt-${count.index + 1}"
  })
}

resource "aws_route" "awspro_private_default" {
  count = var.enable_nat_gateway ? 2 : 0

  route_table_id         = aws_route_table.awspro_private[count.index].id
  destination_cidr_block = "0.0.0.0/0"

  nat_gateway_id = aws_nat_gateway.awspro_nat[
    var.single_nat_gateway ? 0 : count.index
  ].id
}

resource "aws_route_table_association" "awspro_private" {
  count = 2

  subnet_id      = aws_subnet.awspro_private[count.index].id
  route_table_id = aws_route_table.awspro_private[count.index].id
}

# --------------------------------------------------
# OPTIONAL DATABASE ROUTE TABLES
# --------------------------------------------------

resource "aws_route_table" "awspro_database" {
  count = length(var.database_subnet_cidrs) == 2 ? 2 : 0

  vpc_id = aws_vpc.awspro_vpc.id

  tags = merge(local.awspro_common_tags, {
    Name = "${local.awspro_name_prefix}-database-rt-${count.index + 1}"
  })
}

resource "aws_route_table_association" "awspro_database" {
  count = length(var.database_subnet_cidrs) == 2 ? 2 : 0

  subnet_id      = aws_subnet.awspro_database[count.index].id
  route_table_id = aws_route_table.awspro_database[count.index].id
}
