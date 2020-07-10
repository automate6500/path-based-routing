resource "random_string" "alb" {
  length  = 8
  special = false
}

variable load_balancers {
  default = {
    web = {
      port     = 80
      internal = false
    }
    app = {
      port     = 8080
      internal = true
    }
  }
}

resource "aws_security_group" "alb" {
  for_each    = var.load_balancers
  name        = "${terraform.workspace}_${each.key}_${random_string.alb.result}"
  vpc_id      = aws_vpc.vpc.id
  description = "${terraform.workspace} ${each.key} security group"
  tags        = { Name = "${terraform.workspace} ${each.key} security group" }

  ingress {
    from_port   = each.value.port
    to_port     = each.value.port
    protocol    = "6"
    cidr_blocks = ["0.0.0.0/0"]
    description = "The doors of the house are open"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "6"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "dba" {
  name        = "${terraform.workspace}_dba_${random_string.alb.result}"
  vpc_id      = aws_vpc.vpc.id
  description = "${terraform.workspace} dba security group"
  tags        = { Name = "${terraform.workspace} dba security group" }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "6"
    cidr_blocks = ["0.0.0.0/0"]
    description = "The doors of the house are open"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "6"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "alb" {
  for_each           = var.load_balancers
  name               = "${terraform.workspace}-${each.key}"
  load_balancer_type = "application"
  internal           = each.value.internal
  security_groups    = [aws_security_group.alb[each.key].id, aws_security_group.ec2.id]
  subnets            = [for i in aws_subnet.subnets : i.id]
  tags               = { Name = "${terraform.workspace} ${each.key} security group" }
}

resource "aws_lb_target_group" "alb" {
  for_each = var.load_balancers
  name     = "${terraform.workspace}-${each.key}"
  port     = each.value.port
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    interval            = 6
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200"
    protocol            = "HTTP"
    port                = "traffic-port"
  }
}

resource "aws_lb_listener" "alb" {
  for_each          = var.load_balancers
  load_balancer_arn = aws_lb.alb[each.key].arn
  port              = each.value.port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.alb[each.key].arn
    type             = "forward"
  }
}

resource "aws_lb_target_group_attachment" "web" {
  for_each         = aws_instance.web
  target_group_arn = aws_lb_target_group.alb["web"].arn
  target_id        = aws_instance.web[each.key].id
  port             = 80
  depends_on       = [aws_instance.web]
}

resource "aws_lb_target_group_attachment" "app" {
  for_each         = aws_instance.app
  target_group_arn = aws_lb_target_group.alb["app"].arn
  target_id        = aws_instance.app[each.key].id
  port             = 8080
  depends_on       = [aws_instance.app]
}

