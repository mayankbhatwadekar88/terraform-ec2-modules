#1. Create S3 bucket
#2. Enable versioning
#3. Block public access
# nable the s3 encryption
#3. Bucket lifecycle- Delete noncurrent versions and Delete failed multipart upload
#4. Create a bucket policy and attach it to the bucket

resource "aws_kms_key" "terraform_state" {
  description = "Customer-managed KMS key for Terraform state"
  enable_key_rotation = true
  deletion_window_in_days = 7

  policy = file("${path.module}/kms-policy.json")
  tags = merge(
    var.global_tags,
    {
      Name = "terraform-state"
      purpose = "terraform-state-encryption"
    }
  )
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.state_bucket_name

  tags = merge(var.global_tags,
    {
      Name    = var.state_bucket_name
      purpose = "terraform-state"
  })

  #   lifecycle {
  #     prevent_destroy = true
  #   }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "name" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
      kms_master_key_id = aws_kms_key.terraform_state.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.bucket

  rule {
    id     = "retain-noncurrent-state-versions"
    status = "Enabled"

    filter {

    }
    noncurrent_version_expiration {
      noncurrent_days = var.non_current_version_retention_days
    }
  }

  rule {
    id     = "remove-incomplete-multipart-uploads"
    status = "Enabled"

    filter {

    }
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "terraform_state" {
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
  policy = data.aws_iam_policy_document.terraform_state.json
}





