
data "aws_ssm_parameter" "awspro_ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended/image_id"
}

resource "aws_launch_template" "awspro_ecs_lt" {
  name_prefix   = "awspro-ecs-lt-dev-"
  description   = "ECS optimized AL2023 launch template for Dev"
  image_id      = data.aws_ssm_parameter.awspro_ecs_ami.value
  instance_type = var.instance_type

  update_default_version = true

  iam_instance_profile {
    name = var.instance_profile_name
  }

  vpc_security_group_ids = var.security_group_ids

  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -euxo pipefail

    # Register with the existing ECS cluster
    printf 'ECS_CLUSTER=%s\n' '${var.ecs_cluster_name}' \
      >> /etc/ecs/ecs.config

    # ECS-optimized AL2023 normally includes SSM Agent.
    # Install it only if missing; package installation requires network access.
    if ! rpm -q amazon-ssm-agent >/dev/null 2>&1; then
      dnf install -y amazon-ssm-agent
    fi

    systemctl enable amazon-ssm-agent
    systemctl restart amazon-ssm-agent
  EOF
  )

  monitoring {
    enabled = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "awspro-ecs-instance-dev"
      Environment = "dev"
      ManagedBy   = "Terraform"
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Name        = "awspro-ecs-volume-dev"
      Environment = "dev"
      ManagedBy   = "Terraform"
    }
  }
}
