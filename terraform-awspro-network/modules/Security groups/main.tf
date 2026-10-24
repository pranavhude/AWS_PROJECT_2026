
locals {
  awspro_name_prefix = "awspro-${var.project_name}-${var.environment}"

  awspro_common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.tags
  )
}

# --------------------------------------------------
# NLB SECURITY GROUP
# Associate this SG when creating the NLB.
# --------------------------------------------------

resource "aws_security_group" "awspro_nlb_sg" {
  name        = "${local.awspro_name_prefix}-nlb-sg"
  description = "AWSPro NLB SG. Inbound: approved clients TCP 443. Outbound: ALB TCP 443."
  vpc_id      = var.vpc_id

  tags = merge(local.awspro_common_tags, {
    Name = "${local.awspro_name_prefix}-nlb-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "awspro_nlb_https_in" {
  for_each = toset(var.allowed_client_cidrs)

  security_group_id = aws_security_group.awspro_nlb_sg.id
  description       = "Allow approved clients to connect to the NLB on TCP 443."
  cidr_ipv4         = each.value
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

# --------------------------------------------------
# ALB SECURITY GROUP
# Inbound: NLB on TCP 443.
# Outbound: ECS dynamic host ports.
# --------------------------------------------------

resource "aws_security_group" "awspro_alb_sg" {
  name        = "${local.awspro_name_prefix}-alb-sg"
  description = "AWSPro ALB SG. Inbound: NLB TCP 443. Outbound: ECS dynamic host ports."
  vpc_id      = var.vpc_id

  tags = merge(local.awspro_common_tags, {
    Name = "${local.awspro_name_prefix}-alb-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "awspro_alb_https_from_nlb" {
  security_group_id            = aws_security_group.awspro_alb_sg.id
  description                  = "Allow HTTPS traffic from the AWSPro NLB security group."
  referenced_security_group_id = aws_security_group.awspro_nlb_sg.id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
}

resource "aws_vpc_security_group_egress_rule" "awspro_alb_to_ecs" {
  security_group_id            = aws_security_group.awspro_alb_sg.id
  description                  = "Allow ALB application traffic to ECS dynamic host ports."
  referenced_security_group_id = aws_security_group.awspro_ecs_sg.id
  ip_protocol                  = "tcp"
  from_port                    = var.ecs_dynamic_host_port_min
  to_port                      = var.ecs_dynamic_host_port_max
}

# --------------------------------------------------
# NLB OUTBOUND TO ALB
# --------------------------------------------------

resource "aws_vpc_security_group_egress_rule" "awspro_nlb_to_alb" {
  security_group_id            = aws_security_group.awspro_nlb_sg.id
  description                  = "Allow NLB traffic to the ALB HTTPS listener."
  referenced_security_group_id = aws_security_group.awspro_alb_sg.id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
}

# --------------------------------------------------
# ECS EC2 SECURITY GROUP
# Inbound: ALB dynamic host ports.
# Outbound: database, HTTPS and HTTP dependencies.
# --------------------------------------------------

resource "aws_security_group" "awspro_ecs_sg" {
  name        = "${local.awspro_name_prefix}-ecs-sg"
  description = "AWSPro ECS EC2 SG. Inbound: ALB dynamic ports. Outbound: Aurora TCP 5432 and required HTTP/HTTPS."
  vpc_id      = var.vpc_id

  tags = merge(local.awspro_common_tags, {
    Name = "${local.awspro_name_prefix}-ecs-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "awspro_ecs_from_alb" {
  security_group_id            = aws_security_group.awspro_ecs_sg.id
  description                  = "Allow ALB traffic to ECS bridge-mode dynamic host ports."
  referenced_security_group_id = aws_security_group.awspro_alb_sg.id
  ip_protocol                  = "tcp"
  from_port                    = var.ecs_dynamic_host_port_min
  to_port                      = var.ecs_dynamic_host_port_max
}

resource "aws_vpc_security_group_egress_rule" "awspro_ecs_https_out" {
  security_group_id = aws_security_group.awspro_ecs_sg.id
  description       = "Allow HTTPS egress to required AWS APIs and approved dependencies."
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "awspro_ecs_http_out" {
  security_group_id = aws_security_group.awspro_ecs_sg.id
  description       = "Allow HTTP egress for dependencies that require it."
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

# --------------------------------------------------
# AURORA POSTGRESQL SECURITY GROUP
# Create this module separately in each Region/VPC.
# Inbound: ECS workloads on TCP 5432.
# --------------------------------------------------

resource "aws_security_group" "awspro_db_sg" {
  name        = "${local.awspro_name_prefix}-db-sg"
  description = "AWSPro Aurora PostgreSQL SG. Inbound: ECS security group TCP 5432. Outbound: no additional rule required for response traffic."
  vpc_id      = var.vpc_id

  tags = merge(local.awspro_common_tags, {
    Name = "${local.awspro_name_prefix}-db-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "awspro_db_from_ecs" {
  security_group_id            = aws_security_group.awspro_db_sg.id
  description                  = "Allow PostgreSQL connections from AWSPro ECS workloads."
  referenced_security_group_id = aws_security_group.awspro_ecs_sg.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}

resource "aws_vpc_security_group_egress_rule" "awspro_ecs_to_db" {
  security_group_id            = aws_security_group.awspro_ecs_sg.id
  description                  = "Allow ECS workloads to connect to Aurora PostgreSQL."
  referenced_security_group_id = aws_security_group.awspro_db_sg.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}

# --------------------------------------------------
# OPTIONAL BASTION SECURITY GROUP
# --------------------------------------------------

resource "aws_security_group" "awspro_bastion_sg" {
  count = var.create_bastion_sg ? 1 : 0

  name        = "${local.awspro_name_prefix}-bastion-sg"
  description = "AWSPro bastion SG. Inbound: approved admin CIDRs TCP 22. Outbound: ECS SSH TCP 22."
  vpc_id      = var.vpc_id

  tags = merge(local.awspro_common_tags, {
    Name = "${local.awspro_name_prefix}-bastion-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "awspro_bastion_ssh_in" {
  for_each = var.create_bastion_sg ? toset(var.bastion_admin_cidrs) : toset([])

  security_group_id = aws_security_group.awspro_bastion_sg[0].id
  description       = "Allow SSH only from approved administrator CIDRs."
  cidr_ipv4         = each.value
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "awspro_bastion_to_ecs" {
  count = var.create_bastion_sg ? 1 : 0

  security_group_id            = aws_security_group.awspro_bastion_sg[0].id
  description                  = "Allow bastion SSH to ECS instances."
  referenced_security_group_id = aws_security_group.awspro_ecs_sg.id
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
}

resource "aws_vpc_security_group_ingress_rule" "awspro_ecs_ssh_from_bastion" {
  count = var.create_bastion_sg ? 1 : 0

  security_group_id            = aws_security_group.awspro_ecs_sg.id
  description                  = "Allow optional SSH access from the AWSPro bastion security group."
  referenced_security_group_id = aws_security_group.awspro_bastion_sg[0].id
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
}

# --------------------------------------------------
# OPTIONAL INTERFACE VPC ENDPOINT SECURITY GROUP
# --------------------------------------------------

resource "aws_security_group" "awspro_vpce_sg" {
  count = var.create_vpce_sg ? 1 : 0

  name        = "${local.awspro_name_prefix}-vpce-sg"
  description = "AWSPro interface VPC endpoint SG. Inbound: ECS workloads TCP 443."
  vpc_id      = var.vpc_id

  tags = merge(local.awspro_common_tags, {
    Name = "${local.awspro_name_prefix}-vpce-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "awspro_vpce_https_from_ecs" {
  count = var.create_vpce_sg ? 1 : 0

  security_group_id            = aws_security_group.awspro_vpce_sg[0].id
  description                  = "Allow ECS instances to connect to interface VPC endpoints over HTTPS."
  referenced_security_group_id = aws_security_group.awspro_ecs_sg.id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
}

resource "aws_vpc_security_group_egress_rule" "awspro_ecs_to_vpce" {
  count = var.create_vpce_sg ? 1 : 0

  security_group_id            = aws_security_group.awspro_ecs_sg.id
  description                  = "Allow ECS instances to access interface VPC endpoints over HTTPS."
  referenced_security_group_id = aws_security_group.awspro_vpce_sg[0].id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
}
