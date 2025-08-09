output "ecr_repository_url" {
  description = "The URL of the ECR repository for the application Docker images"
  value       = aws_ecr_repository.app_repo.repository_url
}

output "ecs_service_name" {
  description = "The name of the deployed ECS service"
  value       = aws_ecs_service.app_service.name
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.app_cluster.name
}

output "app_lb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_lb.app_lb.dns_name
}