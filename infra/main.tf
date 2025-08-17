provider "aws" {
  region = var.region
}

# --- AWS Secrets Manager ---
resource "aws_secretsmanager_secret" "api_key" {
  name        = "weatherapp-key-v1"
  description = "OpenWeather API Key"
  tags = {
    Application = "weather-app"
    Environment = "production"
  }
}

resource "aws_secretsmanager_secret_version" "api_key_version" {
  secret_id     = aws_secretsmanager_secret.api_key.id
  secret_string = var.api_key
}

# --- ECR Repository ---
resource "aws_ecr_repository" "app_repo" {
  name                 = "weather-app"
  image_tag_mutability = "MUTABLE"
}