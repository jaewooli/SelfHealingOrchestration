data "archive_file" "ingest_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_src/ingest_finding.py"
  output_path = "${path.module}/lambda_src/ingest_finding.zip"
}

data "archive_file" "notify_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_src/notify_slack.py"
  output_path = "${path.module}/lambda_src/notify_slack.zip"
}