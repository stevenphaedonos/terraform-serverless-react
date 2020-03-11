resource "aws_s3_bucket" "project_bucket" {
  bucket = var.project_bucket
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Project     = var.project_name
    Environment = "prod"
  }
}

# Private ACLs and bucket policies for project bucket
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.project_bucket.id

  # Block new public ACLs and uploading public objects
  block_public_acls = true

  # Retroactively remove public access granted through public ACLs
  ignore_public_acls = true

  # Block new public bucket policies
  block_public_policy = true

  # Retroactivley block public and cross-account access if bucket has public policies
  restrict_public_buckets = true
}

# Assign the IAM policy to the project bucket
resource "aws_s3_bucket_policy" "policy_assignment" {
  bucket = aws_s3_bucket.project_bucket.id
  policy = data.aws_iam_policy_document.project_bucket_policy.json
}
