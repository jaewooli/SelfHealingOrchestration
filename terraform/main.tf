data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"] //2023년 버전이므로 후에 버전 확인 후 변경 요망
  }
}
