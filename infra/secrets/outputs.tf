output "secret_arn" {
  description = "The ARN of the weather API key secret in Secrets Manager."
  value       = aws_secretsmanager_secret.api_key.arn
}