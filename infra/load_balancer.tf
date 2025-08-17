# --- Application Load Balancer & Target Groups ---
resource "aws_lb" "app_lb" {
  name               = "weather-app-lb"
  internal           = false
  load_balancer_type = "application"
  # Now using both public subnets for high availability
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  security_groups    = [aws_security_group.lb_sg.id]
}

resource "aws_lb_target_group" "blue_tg" {
  name        = "weather-app-blue-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path = "/health"
    protocol = "HTTP"
    matcher  = "200"
  }
}

resource "aws_lb_target_group" "green_tg" {
  name        = "weather-app-green-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path = "/health"
    protocol = "HTTP"
    matcher  = "200"
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  # The default action forwards traffic to the blue target group
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue_tg.arn
  }
}

# Add a listener rule for the green target group, but make it inactive by default.
resource "aws_lb_listener_rule" "green_rule" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.green_tg.arn
  }

  condition {
    path_pattern {
      values = ["/inactive-green-route"] # Use a specific path for this rule
    }
  }
}