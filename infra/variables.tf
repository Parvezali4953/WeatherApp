variable "region"         { type = string }
variable "project"        { type = string }
variable "environment"    { type = string }
variable "container_port" { type = number }
variable "desired_count"  { type = number }

variable "container_image" { 
  type = string
  default = "none" 
}

variable "api_key" {
  type        = string
  description = "Weather API key to store in Secrets Manager"
  sensitive   = true
}