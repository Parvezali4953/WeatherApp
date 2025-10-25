output "target_group_arn" {
  description = "The ARN of the ECS Target Group."
  value       = aws_lb_target_group.this.arn
}

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer."
  value       = aws_lb.this.dns_name
}
