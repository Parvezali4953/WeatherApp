resource "aws_secretsmanager_secret" "api_key" {
  name        = "${var.project_name}/${var.environment}/weather-api-key"
  description = "Stores the API key for the external weather service."

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# This resource creates a version of the secret and populates it with the actual value.
# The value is passed in securely from a variable.
resource "aws_secretsmanager_secret_version" "api_key_v1" {
  secret_id     = aws_secretsmanager_secret.api_key.id
  secret_string = var.weather_api_key
}
