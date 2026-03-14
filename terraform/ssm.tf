resource "aws_security_group" "vpc2_ec2_sg" {
  name   = "${local.name_prefix}-vpc2-ec2-sg"
  vpc_id = aws_vpc.vpc2.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.operator_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ir_ec2" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.vpc2_private_a.id
  vpc_security_group_ids = [aws_security_group.vpc2_ec2_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ssm_ec2.name
  key_name               = var.key_name

  user_data = <<-EOF
              #!/bin/bash
              dnf install -y python3 docker
              systemctl enable docker
              systemctl start docker
              EOF

  tags = {
    Name = "${local.name_prefix}-ir-ec2"
  }
}

resource "aws_ssm_document" "ir_playbook" {
  name          = "${local.name_prefix}-ir-playbook"
  document_type = "Command"

  content = jsonencode({
    schemaVersion = "2.2"
    description   = "Simple IR playbook"
    mainSteps = [
      {
        action = "aws:runShellScript"
        name   = "runPlaybook"
        inputs = {
          runCommand = [
            "echo Incident response playbook started",
            "date",
            "uname -a"
          ]
        }
      }
    ]
  })
}