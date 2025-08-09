variable "region" {
  description = "AWS region where resources will be deployed"
  type        = string
  default     = "ap-south-1"
}

variable "api_key" {
  description = "OpenWeather API Key (will be stored in AWS Secrets Manager)"
  type        = string
  sensitive   = true
}

variable "aws_account_id" {
  description = "AWS account ID where resources will be deployed"
  type        = string
}

variable "github_org" {
  description = "GitHub organization or username (e.g., 'myorg' or 'myuser')"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name (e.g., 'WeatherApp')"
  type        = string
}