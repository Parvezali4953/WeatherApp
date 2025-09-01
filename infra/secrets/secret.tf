resource "aws_secretsmanager_secret" "weather_api" {
  name        = "${var.project}/${var.environment}/weather_apikey"
  description = "API key for Weather app"
  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "weather_api_v1" {
  secret_id     = aws_secretsmanager_secret.weather_api.id
  secret_string = var.api_key
}
