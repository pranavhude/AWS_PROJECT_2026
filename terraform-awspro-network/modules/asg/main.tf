
resource "aws_autoscaling_group" "awspro_ecs_asg" {
  name                = "awspro-ecs-asg-dev"
  min_size            = var.min_size
  desired_capacity    = var.desired_capacity
  max_size             = var.max_size
  vpc_zone_identifier = var.private_subnet_ids

  health_check_type         = "EC2"
  health_check_grace_period = 300
  capacity_rebalance        = true

  launch_template {
    id      = var.launch_template_id
    version = tostring(var.launch_template_version)
  }

  tag {
    key                 = "Name"
    value               = "awspro-ecs-instance-dev"
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = "true"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "dev"
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}
