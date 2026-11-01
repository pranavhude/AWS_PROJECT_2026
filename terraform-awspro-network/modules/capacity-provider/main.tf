
resource "aws_ecs_capacity_provider" "awspro_ecs_capacity_provider" {
  name = "awspro-ecs-capacity-provider-dev"

  auto_scaling_group_provider {
    auto_scaling_group_arn = var.asg_arn

    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 100
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 2
    }

    managed_termination_protection = "DISABLED"
  }

  tags = {
    Name        = "awspro-ecs-capacity-provider-dev"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

resource "aws_ecs_cluster_capacity_providers" "awspro_cluster_capacity_providers" {
  cluster_name = var.cluster_name

  capacity_providers = [
    aws_ecs_capacity_provider.awspro_ecs_capacity_provider.name
  ]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.awspro_ecs_capacity_provider.name
    weight            = 1
    base              = 0
  }
}
