output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_a_id" {
  value = aws_subnet.public_a.id
}

output "subnet_c_id" {
  value = aws_subnet.public_c.id
}

output "ec2_a_id" {
  value = aws_instance.app_a.id
}

output "ec2_c_id" {
  value = aws_instance.app_c.id
}

output "alb_dns_name" {
  value = aws_lb.app_alb.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.app_tg.arn
}

output "app_sg_id" {
  value = aws_security_group.app_sg.id
}

output "quarantine_sg_id" {
  value = aws_security_group.quarantine_sg.id
}

output "log_bucket_name" {
  value = aws_s3_bucket.logs.bucket
}