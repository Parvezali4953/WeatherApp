variable "project_name" {
  description = "The overall name for the project, used for resource naming."
  type        = string
}

variable "environment" {
  description = "The deployment environment (e.g., 'dev', 'staging', 'prod')."
  type        = string
}

variable "aws_region" {
  description = "The AWS region where all application resources will be deployed."
  type        = string
}

variable "container_port" {
  description = "The port that the application container listens on."
  type        = number
}

variable "container_image" {
  description = "The Docker image URI to be deployed. This is typically provided by a CI/CD pipeline."
  type        = string
}

variable "weather_api_key" {
  description = "The API key for the external weather service. This should be passed in as a secret."
  type        = string
  sensitive   = true # Prevents Terraform from showing this value in cleartext logs.
}
