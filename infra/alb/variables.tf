variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "environment" {
  description = "The deployment environment."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the ALB will be deployed."
  type        = string
}

variable "public_subnet_ids" {
  description = "A list of public subnet IDs for the ALB."
  type        = list(string)
}

variable "alb_sg_id" {
  description = "The ID of the security group to attach to the ALB."
  type        = string
}

variable "container_port" {
  description = "The port the application container listens on."
  type        = number
}
