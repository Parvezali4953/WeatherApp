# This resource creates a private ECR repository.
resource "aws_ecr_repository" "main" {
  name                 = "${var.project_name}-${var.environment}"
  image_tag_mutability = "MUTABLE"

  # This is a key security feature. It automatically scans your Docker images
  # for known software vulnerabilities when they are pushed.
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}
