provider "aws" {
  version = "~> 2.0"
  region  = "us-west-2"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "map_public_ip_on_launch" {
  default = true
}

variable "key" {
  default = {
    name       = "key"
    public_key = "~/.ssh/id_rsa.pub"
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
