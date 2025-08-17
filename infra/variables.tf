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

variable "vpc_cidr_block" {
  description = "The CIDR block for the custom VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "min_capacity" {
  description = "The minimum number of tasks for autoscaling"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "The maximum number of tasks for autoscaling"
  type        = number
  default     = 5
}

variable "cpu_utilization_target" {
  description = "The CPU utilization threshold for scaling"
  type        = number
  default     = 70
}