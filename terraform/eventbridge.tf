resource "aws_lambda_function" "ingest_finding" {
  function_name    = "${local.name_prefix}-ingest-finding"
  role             = aws_iam_role.lambda_ingest_role.arn
  runtime          = "python3.12"
  handler          = "ingest_finding.lambda_handler"
  filename         = data.archive_file.ingest_zip.output_path
  source_code_hash = data.archive_file.ingest_zip.output_base64sha256
  timeout          = 60

  environment {
    variables = {
      BUCKET_NAME       = aws_s3_bucket.logs.bucket
      STEP_FUNCTION_ARN = aws_sfn_state_machine.ir_workflow.arn
      BEDROCK_MODEL_ID  = var.bedrock_model_id
    }
  }
}

resource "aws_lambda_function" "notify_slack" {
  function_name    = "${local.name_prefix}-notify-slack"
  role             = aws_iam_role.lambda_notify_role.arn
  runtime          = "python3.12"
  handler          = "notify_slack.lambda_handler"
  filename         = data.archive_file.notify_zip.output_path
  source_code_hash = data.archive_file.notify_zip.output_base64sha256
  timeout          = 30

  environment {
    variables = {
      SLACK_SECRET_ARN = aws_secretsmanager_secret.slack_webhook.arn
    }
  }
}