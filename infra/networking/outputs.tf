output "vpc_id" {
  description = "The ID of the created VPC."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "A list of IDs for the public subnets."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "A list of IDs for the private subnets."
  value       = aws_subnet.private[*].id
}

output "alb_sg_id" {
  description = "The ID of the security group for the Application Load Balancer."
  value       = aws_security_group.alb.id
}

output "ecs_tasks_sg_id" {
  description = "The ID of the security group for the ECS tasks."
  value       = aws_security_group.ecs_tasks.id
}
