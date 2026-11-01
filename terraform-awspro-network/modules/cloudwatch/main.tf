
resource "aws_cloudwatch_log_group" "awspro_ecs_logs" {
  name              = "/aws/ecs/awspro-ecs-dev"
  retention_in_days = var.log_retention_days

  tags = {
    Name        = "awspro-ecs-logs-dev"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

# Alarm when ECS cluster CPU utilization is high.
resource "aws_cloudwatch_metric_alarm" "awspro_ecs_cpu_high" {
  alarm_name          = "awspro-ecs-cpu-high-dev"
  alarm_description   = "ECS cluster CPU utilization is high"
  namespace           = "AWS/ECS"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = var.cpu_threshold
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = var.cluster_name
  }

  alarm_actions = var.alarm_actions

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

# Alarm when the ASG has fewer in-service instances than expected.
resource "aws_cloudwatch_metric_alarm" "awspro_asg_capacity_low" {
  alarm_name          = "awspro-ecs-asg-capacity-low-dev"
  alarm_description   = "ECS Auto Scaling Group has insufficient in-service instances"
  namespace           = "AWS/AutoScaling"
  metric_name         = "GroupInServiceInstances"
  statistic           = "Minimum"
  period              = 300
  evaluation_periods  = 2
  threshold           = var.min_in_service_instances
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "breaching"

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  alarm_actions = var.alarm_actions

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
