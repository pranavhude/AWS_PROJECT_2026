
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
# AWS SECRETS MANAGER SECRET CONTAINERS
# No plaintext secret values are managed in this module.
# --------------------------------------------------

resource "aws_secretsmanager_secret" "awspro_secret" {
  for_each = var.secret_names

  name        = "${local.awspro_name_prefix}-${each.value}"
  description = "AWSPro ${each.key} secret container for ${var.environment}. Populate the value securely outside Terraform."

  kms_key_id = var.kms_key_arn != "" ? var.kms_key_arn : null

  recovery_window_in_days = var.recovery_window_in_days

  tags = merge(local.awspro_common_tags, {
    Name       = "${local.awspro_name_prefix}-${each.value}"
    SecretType = each.key
  })
}
