variable "project"     { type = string }
variable "environment" { type = string }
variable "region"      { type = string }

variable "api_key" {
  type        = string
  description = "Weather API key"
  sensitive   = true
}