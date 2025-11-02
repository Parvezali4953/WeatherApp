output "log_group_name" {
  description = "The name of the CloudWatch log group for ECS."
  value       = aws_cloudwatch_log_group.ecs_logs.name
}
