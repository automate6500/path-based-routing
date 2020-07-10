locals {
  subnets = {
    a = {
      vpc_id                  = aws_vpc.vpc.id
      cidr_block              = "172.31.48.0/20"
      map_public_ip_on_launch = var.map_public_ip_on_launch
      availability_zone       = "us-west-2a"
    }
    b = {
      vpc_id                  = aws_vpc.vpc.id
      cidr_block              = "172.31.16.0/20"
      map_public_ip_on_launch = var.map_public_ip_on_launch
      availability_zone       = "us-west-2b"
    }
    c = {
      vpc_id                  = aws_vpc.vpc.id
      cidr_block              = "172.31.0.0/20"
      map_public_ip_on_launch = var.map_public_ip_on_launch
      availability_zone       = "us-west-2c"
    }
  }
}
