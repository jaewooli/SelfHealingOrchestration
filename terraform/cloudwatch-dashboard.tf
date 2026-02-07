resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "self-healing-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        x = 0
        y = 0
        width = 12
        height = 6
        properties = {
          title  = "ECS Service CPU / Memory"
          region = "ap-northeast-2"
          metrics = [
            [ "AWS/ECS", "CPUUtilization", "ServiceName", "example-service", "ClusterName", "example-cluster" ],
            [ ".", "MemoryUtilization", ".", ".", ".", "." ]
          ]
          period = 300
          stat   = "Average"
        }
      },
      {
        type = "metric"
        x = 12
        y = 0
        width = 12
        height = 6
        properties = {
          title  = "ALB Request Count / 5XX Errors"
          region = "ap-northeast-2"
          metrics = [
            [ "AWS/ApplicationELB", "RequestCount", "LoadBalancer", "example-alb" ],
            [ ".", "HTTPCode_Target_5XX_Count", ".", "." ]
          ]
          period = 300
          stat   = "Sum"
        }
      },
      {
        type = "metric"
        x = 0
        y = 6
        width = 12
        height = 6
        properties = {
          title  = "Lambda Errors / Invocations"
          region = "ap-northeast-2"
          metrics = [
            [ "AWS/Lambda", "Invocations", "FunctionName", "example-lambda" ],
            [ ".", "Errors", ".", "." ]
          ]
          period = 300
          stat   = "Sum"
        }
      }
    ]
  })
}
