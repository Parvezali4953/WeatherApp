variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "environment" {
  description = "The deployment environment."
  type        = string
}

variable "aws_region" {
  description = "The AWS region where the state backend resources will be created."
  type        = string
}

variable "state_bucket_name" {
  description = "A globally unique name for the S3 bucket that will store Terraform state."
  type        = string
}

variable "lock_table_name" {
  description = "The name of the DynamoDB table used for state locking."
  type        = string
}
