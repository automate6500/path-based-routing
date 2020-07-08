provider "aws" {
  version = "~> 2.0"
  region  = "us-west-2"
}

resource "aws_vpc" "vpc" {
  cidr_block       = "172.31.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "${terraform.workspace} Pluralsight Lab VPC"
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
      map_public_ip_on_launch = true
      availability_zone       = "us-west-2a"
    }
    b = {
      vpc_id                  = aws_vpc.vpc.id
      cidr_block              = "172.31.16.0/20"
      map_public_ip_on_launch = true
      availability_zone       = "us-west-2b"
    }
    c = {
      vpc_id                  = aws_vpc.vpc.id
      cidr_block              = "172.31.0.0/20"
      map_public_ip_on_launch = true
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

data "aws_caller_identity" "current" {}

data "aws_ami" "amazon_linux" {
  most_recent = true
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
  owners = ["137112412989"]
}

resource "aws_security_group" "security_group" {
  description = "${terraform.workspace} EC2 Security Group - all ports open"
  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    },
  ]
  ingress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    },
  ]
  name   = "${terraform.workspace}_security_group"
  tags   = {}
  vpc_id = aws_vpc.vpc.id

  timeouts {}
}

resource "aws_instance" "instance" {
  for_each                    = local.subnets
  ami                         = data.aws_ami.amazon_linux.id
  monitoring                  = false
  associate_public_ip_address = each.value.map_public_ip_on_launch
  availability_zone           = each.value.availability_zone
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.subnets[each.key].id
  tags                        = { Name = "${terraform.workspace}-server-${each.key}" }
  vpc_security_group_ids      = [aws_security_group.security_group.id]
  #user_data                   = file("install_carved_rock_site.sh")
}
