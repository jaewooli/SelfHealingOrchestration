resource "aws_s3_bucket" "logs" {
  bucket = "${var.project_name}-${var.environment}-logs-mvp"

  tags = {
    Name = "${var.project_name}-${var.environment}-logs"
  }
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


resource "aws_s3_object" "raw_findings_prefix" {
  bucket  = aws_s3_bucket.logs.id
  key     = "raw-findings/"
  content = ""
}

resource "aws_s3_object" "normalized_events_prefix" {
  bucket  = aws_s3_bucket.logs.id
  key     = "normalized-events/"
  content = ""
}

resource "aws_s3_object" "action_results_prefix" {
  bucket  = aws_s3_bucket.logs.id
  key     = "action-results/"
  content = ""
}

resource "aws_s3_object" "mem_dump_prefix" {
  bucket  = aws_s3_bucket.logs.id
  key     = "mem-dump/"
  content = ""
}

resource "aws_s3_object" "waf_logs_prefix" {
  bucket  = aws_s3_bucket.logs.id
  key     = "waf-logs/"
  content = ""
}