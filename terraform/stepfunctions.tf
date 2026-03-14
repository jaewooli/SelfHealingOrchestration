resource "aws_sfn_state_machine" "ir_workflow" {
  name     = "${local.name_prefix}-ir-workflow"
  role_arn = aws_iam_role.stepfunctions_role.arn

  definition = jsonencode({
    Comment = "IR workflow"
    StartAt = "NotifySlack"
    States = {
      NotifySlack = {
        Type     = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = aws_lambda_function.notify_slack.arn
          "Payload.$"  = "$"
        }
        ResultPath = "$.slack"
        Next       = "DeregisterFromTargetGroup"
      }

      DeregisterFromTargetGroup = {
        Type     = "Task"
        Resource = "arn:aws:states:::aws-sdk:elasticloadbalancingv2:deregisterTargets"
        Parameters = {
          TargetGroupArn = aws_lb_target_group.app_tg.arn
          Targets = [
            {
              "Id.$" = "$.resource_id"
              Port   = 80
            }
          ]
        }
        ResultPath = "$.deregister"
        Next       = "RunSSMPlaybook"
      }

      RunSSMPlaybook = {
        Type     = "Task"
        Resource = "arn:aws:states:::aws-sdk:ssm:sendCommand"
        Parameters = {
          DocumentName = aws_ssm_document.ir_playbook.name
          InstanceIds  = [aws_instance.ir_ec2.id]
        }
        ResultPath = "$.ssm"
        Next       = "WriteResultToS3"
      }

      WriteResultToS3 = {
        Type     = "Task"
        Resource = "arn:aws:states:::aws-sdk:s3:putObject"
        Parameters = {
          Bucket   = aws_s3_bucket.logs.bucket
          "Key.$"  = "States.Format('action-results/{}.json', $.execution_id)"
          "Body.$" = "States.JsonToString($)"
        }
        End = true
      }
    }
  })
}