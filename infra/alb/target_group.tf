locals {
  hc_path    = "/health"
  hc_matcher = "200"
}

resource "aws_lb_target_group" "this" {
  name        = "${var.project}-${var.environment}-tg"
  port        = var.target_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = local.hc_path
    matcher             = local.hc_matcher
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = { Name = "${var.project}-${var.environment}-tg" }
}
