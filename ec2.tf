resource "aws_security_group" "ec2" {
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
  name   = "${terraform.workspace}_ec2_security_group"
  tags   = {}
  vpc_id = aws_vpc.vpc.id

  timeouts {}
}

resource "aws_instance" "instance" {
  key_name                    = aws_key_pair.key.key_name
  for_each                    = local.subnets
  ami                         = data.aws_ami.amazon_linux.id
  monitoring                  = false
  associate_public_ip_address = each.value.map_public_ip_on_launch
  availability_zone           = each.value.availability_zone
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.subnets[each.key].id
  tags                        = { Name = "${terraform.workspace}-server-${each.key}" }
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  user_data                   = file("user_data.sh")
  lifecycle {
    create_before_destroy = "true"
    ignore_changes        = [tags]
  }
}

resource "aws_key_pair" "key" {
  key_name   = var.key.name
  public_key = file("${var.key.public_key}")
}
