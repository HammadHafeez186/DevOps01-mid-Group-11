# S3 Bucket for article uploads
resource "aws_s3_bucket" "uploads" {
  bucket = "${var.project_name}-uploads"

  tags = {
    Name = "${var.project_name}-uploads"
  }
}

# Enable versioning for the uploads bucket
resource "aws_s3_bucket_versioning" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Server-side encryption for uploads bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access to uploads bucket
resource "aws_s3_bucket_public_access_block" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CORS configuration for uploads bucket
resource "aws_s3_bucket_cors_configuration" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# Lifecycle policy to manage costs
resource "aws_s3_bucket_lifecycle_configuration" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  rule {
    id     = "delete-old-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }

  rule {
    id     = "move-to-ia"
    status = "Enabled"

    filter {}

    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }
  }
}

# IAM policy for S3 access
resource "aws_iam_policy" "s3_uploads" {
  count = var.use_eks ? 1 : 0

  name        = "${var.project_name}-s3-uploads-policy"
  description = "Policy for EKS pods to access S3 uploads bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.uploads.arn,
          "${aws_s3_bucket.uploads.arn}/*"
        ]
      }
    ]
  })
}

# Attach S3 policy to app pods via service account role (created in eks.tf)
resource "aws_iam_role_policy_attachment" "app_s3" {
  count = var.use_eks ? 1 : 0

  role       = aws_iam_role.app_pods[0].name
  policy_arn = aws_iam_policy.s3_uploads[0].arn
}

# Output the bucket name
output "s3_uploads_bucket" {
  value       = aws_s3_bucket.uploads.bucket
  description = "Name of the S3 bucket for uploads"
}

output "s3_uploads_bucket_arn" {
  value       = aws_s3_bucket.uploads.arn
  description = "ARN of the S3 bucket for uploads"
}
