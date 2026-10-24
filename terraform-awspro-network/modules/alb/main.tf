
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
# APPLICATION LOAD BALANCER
# --------------------------------------------------

resource "aws_lb" "awspro_alb" {
  name                       = "${local.awspro_name_prefix}-alb"
  internal                   = false
  load_balancer_type         = "application"
  ip_address_type            = "ipv4"
  security_groups            = [var.alb_security_group_id]
  subnets                    = var.public_subnet_ids
  enable_deletion_protection = var.enable_deletion_protection

  tags = merge(local.awspro_common_tags, {
    Name = "${local.awspro_name_prefix}-alb"
  })
}

# --------------------------------------------------
# ECS TARGET GROUP
# ECS bridge networking with dynamic host ports.
# ECS registers instance ID + actual host port.
# --------------------------------------------------

resource "aws_lb_target_group" "awspro_ecs_tg" {
  name        = "${local.awspro_name_prefix}-tg"
  vpc_id      = var.vpc_id
  target_type = "instance"
  protocol    = "HTTP"
  port        = 80

  deregistration_delay = 30

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = var.health_check_path
    matcher             = var.health_check_matcher
    port                = "traffic-port"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = merge(local.awspro_common_tags, {
    Name = "${local.awspro_name_prefix}-tg"
  })
}

# --------------------------------------------------
# HTTPS LISTENER
# --------------------------------------------------

resource "aws_lb_listener" "awspro_alb_http" {
  load_balancer_arn = aws_lb.awspro_alb.arn
  port              = 80
  protocol          = "HTTP"
  #certificate_arn   = var.acm_certificate_arn
  #ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.awspro_ecs_tg.arn
  }

  tags = merge(local.awspro_common_tags, {
    Name = "${local.awspro_name_prefix}-http-listener"
  })
}
