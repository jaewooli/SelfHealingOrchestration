output "vpc1_id" {
  value = aws_vpc.vpc1.id
}

output "vpc2_id" {
  value = aws_vpc.vpc2.id
}

output "alb_dns_name" {
  value = aws_lb.app_alb.dns_name
}

output "app_target_group_arn" {
  value = aws_lb_target_group.app_tg.arn
}

output "app_a_id" {
  value = aws_instance.app_a.id
}

output "app_c_id" {
  value = aws_instance.app_c.id
}

output "ir_ec2_id" {
  value = aws_instance.ir_ec2.id
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.ir.name
}

output "ecs_service_name" {
  value = aws_ecs_service.ir_worker.name
}

output "log_bucket_name" {
  value = aws_s3_bucket.logs.bucket
}

output "stepfunctions_arn" {
  value = aws_sfn_state_machine.ir_workflow.arn
}