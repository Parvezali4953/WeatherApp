output "ecs_cluster_name" {
  description = "The name of the ECS cluster."
  value       = aws_ecs_cluster.this.name
}

output "ecs_service_name" {
  description = "The name of the ECS service."
  value       = aws_ecs_service.this.name
}

output "ecs_task_definition_arn" {
  description = "The ARN of the ECS Task Definition."
  value       = aws_ecs_task_definition.this.arn
}
