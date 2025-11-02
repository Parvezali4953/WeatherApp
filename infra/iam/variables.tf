variable "project_name" {
  type        = string
  description = "The name of the project, used as a prefix for resource names."
}

variable "environment" {
  type        = string
  description = "The deployment environment (e.g., dev, prod)."
}