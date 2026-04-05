###############################################################################
# modules/remote-state/main.tf
# Phase 6 — Remote State Backend
###############################################################################
# ── Random suffix — avoids S3 bucket name collisions ─────────────────────
resource "random_id" "suffix" {
  byte_length = 4
}

# ── S3 Bucket ─────────────────────────────────────────────────────────────
resource "aws_s3_bucket" "state" {
  bucket        = "${var.project_name}-${var.environment}-tfstate-${random_id.suffix.hex}"
  force_destroy = true

  tags = {
    Name = "${var.project_name}-${var.environment}-tfstate"
  }
}

# ── S3 Versioning ─────────────────────────────────────────────────────────
resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ── S3 Server-Side Encryption ─────────────────────────────────────────────
resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ── S3 Public Access Block ────────────────────────────────────────────────
resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


# ── DynamoDB Table — State Locking ────────────────────────────────────────
resource "aws_dynamodb_table" "lock" {
  name     = "${var.project_name}-${var.environment}-tfstate-lock"
  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  billing_mode = "PAY_PER_REQUEST"
  tags = {
    Name = "${var.project_name}-${var.environment}-tfstate-lock"
  }
}