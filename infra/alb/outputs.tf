output "target_group_arn" {
  description = "The ARN of the main target group."
  value       = aws_lb_target_group.main.arn
}

output "listener" {
  description = "The ALB listener resource, for dependency ordering."
  value       = aws_lb_listener.http
}

output "dns_name" {
  description = "The public DNS name of the load balancer."
  value       = aws_lb.main.dns_name
}
