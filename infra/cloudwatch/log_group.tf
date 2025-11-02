# This resource creates a log group to store container logs.
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name = "/ecs/${var.project_name}-${var.environment}"

  # This is an important cost-control measure. It automatically deletes log
  # events older than 30 days, preventing indefinite storage costs.
  retention_in_days = 30

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}
