
data "aws_wafv2_web_acl" "existing" {
  name  = "existing-waf-name"
  scope = "REGIONAL"
}


output "waf_arn" {
  value = data.aws_wafv2_web_acl.existing.arn
}


resource "aws_guardduty_detector" "existing" {}


import {
  to = aws_guardduty_detector.existing
  id = "d4b02db7096634b077..." # 실제 Detector ID
}