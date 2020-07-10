resource "aws_lb_target_group" "img" {
  name     = "${terraform.workspace}-img"
  port     = 81
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    interval            = 6
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200"
    protocol            = "HTTP"
    path                = "/image.php"
    port                = "traffic-port"
  }

  stickiness {
    type            = "lb_cookie"
    enabled         = true
    cookie_duration = 300
  }
}

resource "aws_lb_listener_rule" "img" {
  listener_arn = aws_lb_listener.alb["web"].arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.img.arn
  }

  condition {
    path_pattern {
      values = ["/image.php"]
    }
  }
}

resource "aws_lb_target_group_attachment" "img" {
  for_each         = aws_instance.web
  port             = 81
  target_group_arn = aws_lb_target_group.img.arn
  target_id        = aws_instance.web[each.key].id
  depends_on       = [aws_instance.web]
}
