variable "region" {
  default = "ap-south-1"
}

variable "api_key" {
  description = "OpenWeather API Key"
  sensitive   = true
}