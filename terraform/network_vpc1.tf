resource "aws_vpc" "vpc1" {
  cidr_block           = local.vpc1_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.name_prefix}-vpc1"
  }
}

resource "aws_internet_gateway" "vpc1" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name = "${local.name_prefix}-vpc1-igw"
  }
}

resource "aws_subnet" "vpc1_public_a" {
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = local.vpc1_public_a
  availability_zone       = local.az_a
  map_public_ip_on_launch = true
  tags                    = { Name = "${local.name_prefix}-vpc1-public-a" }
}

resource "aws_subnet" "vpc1_public_c" {
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = local.vpc1_public_c
  availability_zone       = local.az_c
  map_public_ip_on_launch = true
  tags                    = { Name = "${local.name_prefix}-vpc1-public-c" }
}

resource "aws_subnet" "vpc1_private_a" {
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = local.vpc1_private_a
  availability_zone = local.az_a
  tags              = { Name = "${local.name_prefix}-vpc1-private-a" }
}

resource "aws_subnet" "vpc1_private_c" {
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = local.vpc1_private_c
  availability_zone = local.az_c
  tags              = { Name = "${local.name_prefix}-vpc1-private-c" }
}

resource "aws_eip" "vpc1_nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "vpc1" {
  allocation_id = aws_eip.vpc1_nat.id
  subnet_id     = aws_subnet.vpc1_public_a.id
  tags = {
    Name = "${local.name_prefix}-vpc1-nat"
  }
  depends_on = [aws_internet_gateway.vpc1]
}

resource "aws_route_table" "vpc1_public" {
  vpc_id = aws_vpc.vpc1.id
  tags   = { Name = "${local.name_prefix}-vpc1-public-rt" }
}

resource "aws_route" "vpc1_public_default" {
  route_table_id         = aws_route_table.vpc1_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.vpc1.id
}

resource "aws_route_table_association" "vpc1_public_a" {
  subnet_id      = aws_subnet.vpc1_public_a.id
  route_table_id = aws_route_table.vpc1_public.id
}

resource "aws_route_table_association" "vpc1_public_c" {
  subnet_id      = aws_subnet.vpc1_public_c.id
  route_table_id = aws_route_table.vpc1_public.id
}

resource "aws_route_table" "vpc1_private" {
  vpc_id = aws_vpc.vpc1.id
  tags   = { Name = "${local.name_prefix}-vpc1-private-rt" }
}

resource "aws_route" "vpc1_private_default" {
  route_table_id         = aws_route_table.vpc1_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.vpc1.id
}

resource "aws_route_table_association" "vpc1_private_a" {
  subnet_id      = aws_subnet.vpc1_private_a.id
  route_table_id = aws_route_table.vpc1_private.id
}

resource "aws_route_table_association" "vpc1_private_c" {
  subnet_id      = aws_subnet.vpc1_private_c.id
  route_table_id = aws_route_table.vpc1_private.id
}