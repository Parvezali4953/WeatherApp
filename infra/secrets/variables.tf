variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "environment" {
  description = "The deployment environment."
  type        = string
}

variable "weather_api_key" {
  description = "The API key for the weather service."
  type        = string
  sensitive   = true # Marks the variable as sensitive to prevent it from being shown in logs.
}
