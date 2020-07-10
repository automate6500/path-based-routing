resource "random_string" "alb" {
  length  = 8
  special = false
}

resource "aws_security_group" "ext" {
  name        = "${terraform.workspace}_alb_external_${random_string.alb.result}"
  vpc_id      = aws_vpc.vpc.id
  description = "${terraform.workspace} alb security group external"
  tags        = { Name = "${terraform.workspace} alb security group external" }

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_security_group" "int" {
  name        = "${terraform.workspace}_alb_internal_${random_string.alb.result}"
  vpc_id      = aws_vpc.vpc.id
  description = "${terraform.workspace} alb security group internal"
  tags        = { Name = "${terraform.workspace} alb security group internal" }

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

resource "aws_lb" "ext" {
  name               = "${terraform.workspace}-ext"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ext.id, aws_security_group.ec2.id]
  subnets            = [for i in aws_subnet.subnets : i.id]
  tags               = { Name = "${terraform.workspace} external alb security group" }
}

resource "aws_lb_target_group" "ext" {
  name     = "${terraform.workspace}-ext"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    interval            = 6
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_listener" "ext" {
  load_balancer_arn = aws_lb.ext.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.ext.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group_attachment" "ext" {
  for_each         = aws_instance.web
  target_group_arn = aws_lb_target_group.ext.arn
  target_id        = aws_instance.web[each.key].id
  port             = 80
  depends_on       = [aws_instance.web]
}
