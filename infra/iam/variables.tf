variable "project_name" {
  type        = string
  description = "The name of the project, used as a prefix for resource names."
}

variable "environment" {
  type        = string
  description = "The deployment environment (e.g., dev, prod)."
}

variable "secrets_manager_secret_arn" {
  description = "The ARN of the Secrets Manager secret that the ECS task needs to access."
  type        = string
}