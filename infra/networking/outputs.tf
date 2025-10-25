output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs."
  value       = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

output "private_subnet_ids" {
  description = "List of private subnet IDs."
  value       = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}

output "alb_sg_id" {
  description = "The security group ID for the Application Load Balancer."
  value       = aws_security_group.alb.id
}

output "app_sg_id" {
  description = "The security group ID for the ECS Fargate tasks."
  value       = aws_security_group.app.id
}
