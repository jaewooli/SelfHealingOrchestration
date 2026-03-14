resource "aws_instance" "app_a" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_a.id
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  user_data = <<-EOF
              #!/bin/bash
              dnf install -y httpd
              echo "Hello from app-a" > /var/www/html/index.html
              systemctl enable httpd
              systemctl start httpd
              EOF

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2-a"
    Role = "app"
    AZ   = "${var.aws_region}a"
  }
}

resource "aws_instance" "app_c" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_c.id
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  user_data = <<-EOF
              #!/bin/bash
              dnf install -y httpd
              echo "Hello from app-c" > /var/www/html/index.html
              systemctl enable httpd
              systemctl start httpd
              EOF

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2-c"
    Role = "app"
    AZ   = "${var.aws_region}c"
  }
}