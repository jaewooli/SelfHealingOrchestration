resource "aws_secretsmanager_secret" "slack_webhook" {
  name = "${local.name_prefix}-slack-webhook"
}

resource "aws_secretsmanager_secret_version" "slack_webhook" {
  secret_id     = aws_secretsmanager_secret.slack_webhook.id
  secret_string = var.slack_webhook_url
}