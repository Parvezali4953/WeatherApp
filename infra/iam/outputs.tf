output "execution_role_arn" {
  description = "The ARN for the ECS Task Execution Role."
  value       = aws_iam_role.execution.arn
}

output "task_role_arn" {
  description = "The ARN for the ECS Task Role."
  value       = aws_iam_role.task.arn
}
