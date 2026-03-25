# GuardDuty 탐지기 활성화
resource "aws_guardduty_detector" "main" {
  enable = true

  # S3 및 Malware Protection 옵션 (필요 시)
  datasources {
    s3_logs {
      enable = true
    }
  }
}
resource "aws_wafv2_web_acl" "main" {
  name        = "combined-security-rule"
  description = "WAF for EC2/ALB Protection"
  scope       = "REGIONAL" # CloudFront라면 CLOUDFRONT로 변경

  default_action {
    allow {}
  }

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "main-waf-metric"
    sampled_requests_enabled   = true
  }
}