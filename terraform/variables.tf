variable "aws_region" {
  type    = string
  default = "ap-northeast-2"
}

variable "project_name" {
  type    = string
  default = "antifragile"
}

variable "environment" {
  type    = string
  default = "mvp"
}

variable "owner" {
  type    = string
  default = "team-antifragile"
}

variable "operator_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

variable "slack_webhook_url" {
  type      = string
  sensitive = true
}

variable "bedrock_model_id" {
  type    = string
  // 임시 모델
  default = "anthropic.claude-3-5-sonnet-20241022-v2:0"
}

variable "container_image" {
  type    = string
  default = "public.ecr.aws/docker/library/nginx:latest"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
  default     = null
}