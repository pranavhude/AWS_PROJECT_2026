
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

  # ------------------------------------------------
  # ECS EC2 INSTANCE PERMISSIONS
  # ------------------------------------------------

  awspro_ec2_policy_statements = concat(
    [
      {
        Effect = "Allow"
        Action = [
          "ecs:DiscoverPollEndpoint",
          "ecs:Poll",
          "ecs:RegisterContainerInstance",
          "ecs:StartTelemetrySession",
          "ecs:SubmitAttachmentStateChanges",
          "ecs:SubmitContainerStateChange",
          "ecs:SubmitTaskStateChange",
          "ecs:UpdateContainerInstancesState",
          "ecs:ListClusters",
          "ecs:DescribeClusters",
          "ecs:ListContainerInstances",
          "ecs:DescribeContainerInstances",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeTasks",
          "ecs:ListTasks"
        ]
        Resource = "*"
      }
    ],
    var.enable_ssm ? [
      {
        Effect = "Allow"
        Action = [
          "ssm:UpdateInstanceInformation",
          "ssm:DescribeAssociation",
          "ssm:ListInstanceAssociations",
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel",
          "ec2messages:AcknowledgeMessage",
          "ec2messages:DeleteMessage",
          "ec2messages:FailMessage",
          "ec2messages:GetEndpoint",
          "ec2messages:GetMessages",
          "ec2messages:SendReply"
        ]
        Resource = "*"
      }
    ] : []
  )

  awspro_ec2_policy = {
    Version   = "2012-10-17"
    Statement = local.awspro_ec2_policy_statements
  }

  # ------------------------------------------------
  # ECS TASK EXECUTION PERMISSIONS
  # ------------------------------------------------

  awspro_execution_policy_statements = concat(
    [
      {
        Sid      = "ECRAuthorization"
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Sid    = "ECRImagePull"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = var.ecr_repository_arns
      },
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${var.cloudwatch_log_group_arn}:*"
      }
    ],
    length(var.secret_arns) > 0 ? [
      {
        Sid      = "ReadApplicationSecrets"
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = var.secret_arns
      }
    ] : [],
    length(var.secret_arns) > 0 && var.kms_key_arn != "" ? [
      {
        Sid      = "DecryptApplicationSecrets"
        Effect   = "Allow"
        Action   = ["kms:Decrypt"]
        Resource = var.kms_key_arn
      }
    ] : []
  )

  awspro_execution_policy = {
    Version   = "2012-10-17"
    Statement = local.awspro_execution_policy_statements
  }

  # ------------------------------------------------
  # ECS APPLICATION TASK PERMISSIONS
  # Only add permissions explicitly requested by the app.
  # ------------------------------------------------

  awspro_task_policy_statements = [
    for statement in var.task_policy_statements : merge(
      {
        Effect   = "Allow"
        Action   = statement.actions
        Resource = statement.resources
      },
      statement.sid == null ? {} : { Sid = statement.sid }
    )
  ]

  awspro_task_policy = {
    Version   = "2012-10-17"
    Statement = local.awspro_task_policy_statements
  }
}

# ==================================================
# ROLE 1: ECS EC2 INSTANCE ROLE
# ==================================================

resource "aws_iam_role" "awspro_ecs_ec2_instance_role" {
  name        = "awspro-ecs-ec2-instance-role"
  description = "AWSPro ECS EC2 instance role for ECS agent operations and optional SSM access."

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(local.awspro_common_tags, {
    Name = "awspro-ecs-ec2-instance-role"
  })
}

resource "aws_iam_role_policy" "awspro_ecs_instance_inline_policy" {
  name   = "awspro-ecs-instance-inline-policy"
  role   = aws_iam_role.awspro_ecs_ec2_instance_role.id
  policy = jsonencode(local.awspro_ec2_policy)
}

resource "aws_iam_instance_profile" "awspro_ecs_instance_profile" {
  name = "awspro-ecs-ec2-instance-profile"
  role = aws_iam_role.awspro_ecs_ec2_instance_role.name

  tags = merge(local.awspro_common_tags, {
    Name = "awspro-ecs-ec2-instance-profile"
  })
}

# ==================================================
# ROLE 2: ECS TASK EXECUTION ROLE
# Used by ECS to pull images, publish logs and fetch
# secrets injected into containers at startup.
# ==================================================

resource "aws_iam_role" "awspro_ecs_task_execution_role" {
  name        = "awspro-ecs-task-execution-role"
  description = "AWSPro ECS task execution role for ECR image pulls, CloudWatch logs and configured secrets."

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(local.awspro_common_tags, {
    Name = "awspro-ecs-task-execution-role"
  })
}

resource "aws_iam_role_policy" "awspro_ecs_execution_inline_policy" {
  name   = "awspro-ecs-execution-inline-policy"
  role   = aws_iam_role.awspro_ecs_task_execution_role.id
  policy = jsonencode(local.awspro_execution_policy)
}

# ==================================================
# ROLE 3: ECS APPLICATION TASK ROLE
# Used by application code inside the container.
# ==================================================

resource "aws_iam_role" "awspro_ecs_task_role" {
  name        = "awspro-ecs-task-role"
  description = "AWSPro ECS application task role for explicitly configured application permissions."

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(local.awspro_common_tags, {
    Name = "awspro-ecs-task-role"
  })
}

resource "aws_iam_role_policy" "awspro_ecs_application_inline_policy" {
  count = length(var.task_policy_statements) > 0 ? 1 : 0

  name   = "awspro-ecs-application-inline-policy"
  role   = aws_iam_role.awspro_ecs_task_role.id
  policy = jsonencode(local.awspro_task_policy)
}
