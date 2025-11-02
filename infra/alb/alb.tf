# 1. Application Load Balancer (ALB)
#
# This is the main resource that receives incoming traffic from the internet
# and distributes it to the registered targets. We place it in the public
# subnets so it is accessible from the outside world.
# -----------------------------------------------------------------------------
resource "aws_lb" "main" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# -----------------------------------------------------------------------------
# 2. Target Group
#
# A target group is used to route requests to one or more registered targets,
# such as ECS tasks. The `target_type` is set to 'ip' because we are using
# Fargate, which assigns an IP address to each task. The health check ensures
# that the ALB only sends traffic to healthy tasks.
# -----------------------------------------------------------------------------
resource "aws_lb_target_group" "main" {
  name        = "${var.project_name}-${var.environment}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    # The ALB will send requests to this path to check if the container is healthy.
    path                = "/health"
    matcher             = "200" # Expects a 200 OK status code for a healthy target.
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# -----------------------------------------------------------------------------
# 3. ALB Listener
#
# A listener checks for connection requests from clients, using the protocol
# and port that you configure. The rule defined here is simple: listen for
# HTTP traffic on port 80 and forward it to our main target group.
# -----------------------------------------------------------------------------
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}
