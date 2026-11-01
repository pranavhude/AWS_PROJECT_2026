
resource "aws_ecs_service" "awspro_ecs_service" {
  name            = "awspro-ecs-service-dev"
  cluster         = var.cluster_arn
  task_definition = var.task_definition_arn
  desired_count   = var.desired_count
  launch_type     = "EC2"

  # Bridge networking with dynamic host ports.
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  health_check_grace_period_seconds  = 60

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = {
    Name        = "awspro-ecs-service-dev"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
