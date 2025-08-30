resource "aws_lb" "this" {
  name               = "${var.project}-${var.environment}-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids
  tags = { Name = "${var.project}-${var.environment}-alb" }
}