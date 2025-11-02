output "application_url" {
  description = "The public URL where the application can be accessed."
  value       = "http://${module.alb.dns_name}"
}

output "ecs_cluster_name" {
  description = "The name of the ECS Cluster created."
  value       = module.ecs.ecs_cluster_name
}

output "ecr_repository_url" {
  description = "The URL of the ECR repository for Docker images."
  value       = module.ecr.repository_url
}

output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch Log Group where container logs are sent."
  value       = module.cloudwatch.log_group_name
}
