provider "aws" {
  version = "~> 2.0"
  region  = "us-west-2"
}

variable "instance_type" {
  default = "t3a.medium"
}

variable "map_public_ip_on_launch" {
  default = true
}

variable "user" {
  default = "ec2-user"
}

variable "key" {
  default = {
    name        = "terraform"
    public_key  = "public_key.pub"
    private_key = "private_key.pem"
  }
}

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
