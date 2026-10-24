
locals {
  awspro_repository_name = "awspro-${var.project_name}-${var.environment}-${var.repository_name}"

  awspro_common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.tags
  )

  awspro_lifecycle_policy = {
    rules = [
      {
        rulePriority = 1
        description = "Expire untagged images older than the configured retention period."
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = var.untagged_image_retention_days
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description = "Retain only the configured number of recent tagged images."
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = var.images_to_retain
        }
        action = {
          type = "expire"
        }
      }
    ]
  }
}

# --------------------------------------------------
# ECR PRIVATE REPOSITORY
# --------------------------------------------------

resource "aws_ecr_repository" "awspro_ecr_repository" {
  name                 = local.awspro_repository_name
  image_tag_mutability = var.image_tag_mutability
  force_delete         = false

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = var.kms_key_arn != "" ? "KMS" : "AES256"
    kms_key         = var.kms_key_arn != "" ? var.kms_key_arn : null
  }

  tags = merge(local.awspro_common_tags, {
    Name = local.awspro_repository_name
  })
}

# --------------------------------------------------
# ECR LIFECYCLE POLICY
# --------------------------------------------------

resource "aws_ecr_lifecycle_policy" "awspro_ecr_lifecycle" {
  repository = aws_ecr_repository.awspro_ecr_repository.name
  policy     = jsonencode(local.awspro_lifecycle_policy)
}
