resource "aws_s3_bucket" "logs" {
  bucket = "${var.project_name}-${var.environment}-logs-example-001"

  tags = {
    Name = "${var.project_name}-${var.environment}-logs"
  }
}

resource "aws_s3_bucket_versioning" "logs_versioning" {
  bucket = aws_s3_bucket.logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs_encryption" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}