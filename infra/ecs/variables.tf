variable "project" { type = string }
variable "environment" { type = string }
variable "region" { type = string }
variable "cluster_sg_id" { type = string }

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the ECS Fargate tasks."
  type        = list(string)
}

variable "container_port" { type = number }
variable "desired_count" { type = number }
variable "container_image" { type = string }
variable "log_group_name" { type = string }
variable "execution_role_arn" { type = string }
variable "task_role_arn" { type = string } # Added for the ECS Task Role
variable "target_group_arn" { type = string }
variable "weather_api_secret_arn" { type = string }
