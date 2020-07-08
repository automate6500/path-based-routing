resource "aws_vpc" "vpc" {
  cidr_block       = "172.31.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "${terraform.workspace} VPC"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route" "route" {
  route_table_id         = aws_vpc.vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gateway.id
}

locals {
  subnets = {
    a = {
      vpc_id                  = aws_vpc.vpc.id
      cidr_block              = "172.31.48.0/20"
      map_public_ip_on_launch = false
      availability_zone       = "us-west-2a"
    }
    b = {
      vpc_id                  = aws_vpc.vpc.id
      cidr_block              = "172.31.16.0/20"
      map_public_ip_on_launch = false
      availability_zone       = "us-west-2b"
    }
    c = {
      vpc_id                  = aws_vpc.vpc.id
      cidr_block              = "172.31.0.0/20"
      map_public_ip_on_launch = false
      availability_zone       = "us-west-2c"
    }
  }
}

resource "aws_subnet" "subnets" {
  for_each                = local.subnets
  vpc_id                  = each.value.vpc_id
  cidr_block              = each.value.cidr_block
  map_public_ip_on_launch = each.value.map_public_ip_on_launch
  availability_zone       = each.value.availability_zone
}