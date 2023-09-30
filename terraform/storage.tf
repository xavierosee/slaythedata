provider "aws" {
  profile = "default"
  region  = var.aws_region
}

# Customer managed KMS key #
resource "aws_kms_key" "kms_s3_key" {
  description             = "Key to protect S3 objects"
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 7
  is_enabled              = true
}

resource "aws_kms_alias" "kms_s3_key_alias" {
  name          = "alias/s3-key"
  target_key_id = aws_kms_key.kms_s3_key.key_id
}

# Bucket creation #
resource "aws_s3_bucket" "data_bucket" {
  bucket = var.raw_data_bucket_name
}

# bucket private access #
resource "aws_s3_bucket_acl" "data_bucket_acl" {
  bucket = aws_s3_bucket.data_bucket.id
  acl    = "private"
}

# Bucket versioning #
resource "aws_s3_bucket_versioning" "data_bucket_versioning" {
  bucket = aws_s3_bucket.data_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Server-side encryption #
resource "aws_s3_bucket_server_side_encryption_configuration" "data_bucket_server_side_encryption" {
  bucket = aws_s3_bucket.data_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.kms_s3_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# Lifecycle rule #
resource "aws_s3_bucket_lifecycle_configuration" "data_bucket_lifecycle_rule" {
  # Bucket versioning must be enabled first
  depends_on = [aws_s3_bucket_versioning.data_bucket_versioning]

  bucket = aws_s3_bucket.data_bucket.bucket

  rule {
    id     = "basic_config"
    status = "Enabled"

    filter {
      prefix = "config/"
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = 60
      storage_class   = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

# Disabling Public Access #
resource "aws_s3_bucket_public_access_block" "data_bucket_access" {
  bucket = aws_s3_bucket.data_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
