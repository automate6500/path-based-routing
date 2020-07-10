locals {
  subnets = {
    1 = {
      vpc_id                  = aws_vpc.vpc.id
      cidr_block              = "172.31.48.0/20"
      map_public_ip_on_launch = var.map_public_ip_on_launch
      availability_zone       = "us-west-2a"
    }
    2 = {
      vpc_id                  = aws_vpc.vpc.id
      cidr_block              = "172.31.16.0/20"
      map_public_ip_on_launch = var.map_public_ip_on_launch
      availability_zone       = "us-west-2b"
    }
    3 = {
      vpc_id                  = aws_vpc.vpc.id
      cidr_block              = "172.31.0.0/20"
      map_public_ip_on_launch = var.map_public_ip_on_launch
      availability_zone       = "us-west-2c"
    }
  }
}
