output "ecr_repository_url" {
  description = "The URL of the ECR repository for the application Docker images"
  value       = aws_ecr_repository.app_repo.repository_url
}

output "ecs_service_name" {
  description = "The name of the deployed ECS service"
  value       = aws_ecs_service.app_service.name
}

# Consider adding these useful outputs if you have the resources defined:
output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.app_cluster.name
}