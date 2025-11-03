variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "environment" {
  description = "The deployment environment."
  type        = string
}

variable "aws_region" {
  description = "The AWS region where resources will be created."
  type        = string
}

variable "private_subnet_ids" {
  description = "A list of private subnet IDs for the ECS tasks."
  type        = list(string)
}

variable "ecs_sg_id" {
  description = "The ID of the security group for the ECS tasks."
  type        = string
}

variable "ecs_task_execution_role_arn" {
  description = "The ARN of the IAM role for ECS task execution."
  type        = string
}

variable "ecs_task_role_arn" {
  description = "The ARN of the IAM role for the application task."
  type        = string
}

variable "alb_target_group_arn" {
  description = "The ARN of the Application Load Balancer target group."
  type        = string
}

variable "alb_listener" {
  description = "The ALB listener resource, used for dependency."
  type        = any
}

variable "container_image" {
  description = "The Docker image to use for the container."
  type        = string
  default     = "nginx:latest" # Default image for initial setup
}

variable "container_port" {
  description = "The port the container listens on."
  type        = number
  default     = 5000
}

variable "container_cpu" {
  description = "The number of CPU units to reserve for the container."
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "The amount of memory (in MiB) to reserve for the container."
  type        = number
  default     = 512
}

variable "min_tasks" {
  description = "The minimum number of tasks to run."
  type        = number
  default     = 1
}

variable "max_tasks" {
  description = "The maximum number of tasks to run for autoscaling."
  type        = number
  default     = 3
}

variable "secret_arn" {
  description = "The ARN of the secret to be injected into the container."
  type        = string
}

variable "log_group_name" {
  description = "The name of the CloudWatch Log Group for the container logs."
  type        = string
}