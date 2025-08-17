output "ecr_repository_url" {
  description = "The URL of the ECR repository for the application Docker images"
  value       = aws_ecr_repository.app_repo.repository_url
}

output "ecs_service_name" {
  description = "The name of the deployed ECS service"
  value       = aws_ecs_service.blue.name
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.app_cluster.name
}

output "app_lb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_lb.app_lb.dns_name
}

output "vpc_id" {
  description = "The ID of the custom VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id_a" {
  description = "The ID of the public subnet A"
  value       = aws_subnet.public_a.id
}

output "public_subnet_id_b" {
  description = "The ID of the public subnet B"
  value       = aws_subnet.public_b.id
}

output "private_subnet_id_a" {
  description = "The ID of the private subnet A"
  value       = aws_subnet.private_a.id
}

output "private_subnet_id_b" {
  description = "The ID of the private subnet B"
  value       = aws_subnet.private_b.id
}