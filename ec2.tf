resource "random_string" "ec2" {
  length  = 8
  special = false
}

resource "aws_security_group" "ec2" {
  name        = "${terraform.workspace}_ec2_security_group_${random_string.ec2.result}"
  vpc_id      = aws_vpc.vpc.id
  description = "${terraform.workspace} ec2 security group"
  tags        = { Name = "${terraform.workspace} ec2 security group" }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "The doors of the house are open"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  for_each                    = local.subnets
  ami                         = data.aws_ami.amazon_linux.id
  associate_public_ip_address = each.value.map_public_ip_on_launch
  availability_zone           = each.value.availability_zone
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.key.key_name
  monitoring                  = false
  subnet_id                   = aws_subnet.subnets[each.key].id
  tags                        = { Name = "${terraform.workspace}-web${each.key}" }
  user_data                   = file("user_data.sh")
  vpc_security_group_ids      = [aws_security_group.ec2.id]

  lifecycle {
    create_before_destroy = "true"
    ignore_changes        = [tags]
  }

  connection {
    type        = "ssh"
    user        = var.user
    private_key = file(var.key.private_key)
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 60",
      "sudo docker run --name web${each.key} --restart always --hostname web${each.key} --env APPSERVER=http://${aws_lb.alb["app"].dns_name}:8080 --detach --publish 80:80 benpiper/mtwa:web",
      "sudo docker run --name img${each.key} --restart always --hostname imagegen${each.key} --detach --publish 81:80 benpiper/imagegen"
    ]
  }
}

resource "aws_instance" "app" {
  for_each                    = local.subnets
  ami                         = data.aws_ami.amazon_linux.id
  associate_public_ip_address = each.value.map_public_ip_on_launch
  availability_zone           = each.value.availability_zone
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.key.key_name
  monitoring                  = false
  subnet_id                   = aws_subnet.subnets[each.key].id
  tags                        = { Name = "${terraform.workspace}-app${each.key}" }
  user_data                   = file("user_data.sh")
  vpc_security_group_ids      = [aws_security_group.ec2.id]

  lifecycle {
    create_before_destroy = "true"
    ignore_changes        = [tags]
  }

  connection {
    type        = "ssh"
    user        = var.user
    private_key = file(var.key.private_key)
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 60",
      "sudo docker run --name app --restart always --hostname app${each.key} --detach --publish 8080:8080 benpiper/mtwa:app",
    ]
  }
}
