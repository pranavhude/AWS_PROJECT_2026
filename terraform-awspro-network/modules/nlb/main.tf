
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
# NETWORK LOAD BALANCER
# --------------------------------------------------

resource "aws_lb" "awspro_nlb" {
  name                             = "${local.awspro_name_prefix}-nlb"
  internal                         = false
  load_balancer_type               = "network"
  ip_address_type                  = "ipv4"
  subnets                          = var.public_subnet_ids
  security_groups                  = [var.nlb_security_group_id]
  enable_cross_zone_load_balancing = true
  enable_deletion_protection       = var.enable_deletion_protection

  tags = merge(local.awspro_common_tags, {
    Name = "${local.awspro_name_prefix}-nlb"
  })
}

# --------------------------------------------------
# NLB TARGET GROUP
# Target type ALB; target port must match ALB listener.
# --------------------------------------------------

resource "aws_lb_target_group" "awspro_alb_tg" {
  name        = "${local.awspro_name_prefix}-alb-tg"
  vpc_id      = var.vpc_id
  target_type = "alb"
  protocol    = "HTTP"
  port        = 80

  health_check {
    enabled  = true
    protocol = "TCP"
    port     = "traffic-port"
  }

  tags = merge(local.awspro_common_tags, {
    Name = "${local.awspro_name_prefix}-alb-tg"
  })
}

# --------------------------------------------------
# REGISTER THE ALB AS THE NLB TARGET
# --------------------------------------------------

resource "aws_lb_target_group_attachment" "awspro_alb_attachment" {
  target_group_arn = aws_lb_target_group.awspro_alb_tg.arn
  target_id        = var.alb_arn
  port             = 443
}

# --------------------------------------------------
# NLB TCP LISTENER
# --------------------------------------------------

resource "aws_lb_listener" "awspro_nlb_tcp_443" {
  load_balancer_arn = aws_lb.awspro_nlb.arn
  port              = 443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.awspro_alb_tg.arn
  }

  tags = merge(local.awspro_common_tags, {
    Name = "${local.awspro_name_prefix}-nlb-listener-443"
  })
}
