data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

locals {
  state_bucket_name = join("-", [
    "tfstate",
    var.project_name,
    data.aws_caller_identity.current.account_id,
    var.aws_region
  ])

  common_tags = merge(
    var.common_tags,
    {
      Project     = var.project_name
      ManagedBy   = "Terraform"
      Component   = "Bootstrap"
      Environment = "Shared"
    }
  )
}

# --------------------------------------------------
# KMS KEY FOR TERRAFORM STATE ENCRYPTION
# --------------------------------------------------

resource "aws_kms_key" "terraform_state" {
  description             = "KMS key for Terraform remote state encryption"
  enable_key_rotation     = true
  deletion_window_in_days = var.kms_deletion_window_days

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-terraform-state-key"
  })
}

resource "aws_kms_alias" "terraform_state" {
  name          = "alias/${var.project_name}-terraform-state"
  target_key_id = aws_kms_key.terraform_state.key_id
}

# --------------------------------------------------
# S3 BUCKET
# --------------------------------------------------

resource "aws_s3_bucket" "terraform_state" {
  bucket        = local.state_bucket_name
  force_destroy = false

  tags = merge(local.common_tags, {
    Name = local.state_bucket_name
  })

  lifecycle {
    prevent_destroy = true
  }
}

# --------------------------------------------------
# S3 VERSIONING
# --------------------------------------------------

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# --------------------------------------------------
# S3 SERVER-SIDE ENCRYPTION WITH KMS
# --------------------------------------------------

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.terraform_state.arn
    }

    bucket_key_enabled = true
  }

  depends_on = [
    aws_s3_bucket_versioning.terraform_state
  ]
}

# --------------------------------------------------
# BLOCK ALL PUBLIC ACCESS
# --------------------------------------------------

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# --------------------------------------------------
# S3 OBJECT OWNERSHIP
# --------------------------------------------------

resource "aws_s3_bucket_ownership_controls" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# --------------------------------------------------
# DENY INSECURE HTTP ACCESS
# --------------------------------------------------

data "aws_iam_policy_document" "terraform_state_bucket" {
  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:*"
    ]

    resources = [
      aws_s3_bucket.terraform_state.arn,
      "${aws_s3_bucket.terraform_state.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  policy = data.aws_iam_policy_document.terraform_state_bucket.json

  depends_on = [
    aws_s3_bucket_public_access_block.terraform_state
  ]
}

# --------------------------------------------------
# ABORT INCOMPLETE MULTIPART UPLOADS
# --------------------------------------------------

resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    id     = "abort-incomplete-multipart-uploads"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}