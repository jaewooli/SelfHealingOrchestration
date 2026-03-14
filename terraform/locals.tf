locals {
  name_prefix = "${var.project_name}-${var.environment}"

  vpc1_cidr = "10.10.0.0/16"
  vpc2_cidr = "10.20.0.0/16"

  vpc1_public_a  = "10.10.1.0/24"
  vpc1_public_c  = "10.10.2.0/24"
  vpc1_private_a = "10.10.11.0/24"
  vpc1_private_c = "10.10.12.0/24"

  vpc2_public_a  = "10.20.1.0/24"
  vpc2_private_a = "10.20.11.0/24"

  az_a = "${var.aws_region}a"
  az_c = "${var.aws_region}c"

  s3_bucket_logs = "${local.name_prefix}-logs-mvp"
}