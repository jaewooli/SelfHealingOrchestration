resource "aws_vpc" "vpc2" {
  cidr_block           = local.vpc2_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.name_prefix}-vpc2"
  }
}

resource "aws_internet_gateway" "vpc2" {
  vpc_id = aws_vpc.vpc2.id
  tags = {
    Name = "${local.name_prefix}-vpc2-igw"
  }
}

resource "aws_subnet" "vpc2_public_a" {
  vpc_id                  = aws_vpc.vpc2.id
  cidr_block              = local.vpc2_public_a
  availability_zone       = local.az_a
  map_public_ip_on_launch = true
  tags                    = { Name = "${local.name_prefix}-vpc2-public-a" }
}

resource "aws_subnet" "vpc2_private_a" {
  vpc_id            = aws_vpc.vpc2.id
  cidr_block        = local.vpc2_private_a
  availability_zone = local.az_a
  tags              = { Name = "${local.name_prefix}-vpc2-private-a" }
}

resource "aws_eip" "vpc2_nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "vpc2" {
  allocation_id = aws_eip.vpc2_nat.id
  subnet_id     = aws_subnet.vpc2_public_a.id
  tags = {
    Name = "${local.name_prefix}-vpc2-nat"
  }
  depends_on = [aws_internet_gateway.vpc2]
}

resource "aws_route_table" "vpc2_public" {
  vpc_id = aws_vpc.vpc2.id
  tags   = { Name = "${local.name_prefix}-vpc2-public-rt" }
}

resource "aws_route" "vpc2_public_default" {
  route_table_id         = aws_route_table.vpc2_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.vpc2.id
}

resource "aws_route_table_association" "vpc2_public_a" {
  subnet_id      = aws_subnet.vpc2_public_a.id
  route_table_id = aws_route_table.vpc2_public.id
}

resource "aws_route_table" "vpc2_private" {
  vpc_id = aws_vpc.vpc2.id
  tags   = { Name = "${local.name_prefix}-vpc2-private-rt" }
}

resource "aws_route" "vpc2_private_default" {
  route_table_id         = aws_route_table.vpc2_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.vpc2.id
}

resource "aws_route_table_association" "vpc2_private_a" {
  subnet_id      = aws_subnet.vpc2_private_a.id
  route_table_id = aws_route_table.vpc2_private.id
}