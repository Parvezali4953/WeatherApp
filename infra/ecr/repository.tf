resource "aws_ecr_repository" "this" {
  name = "${var.project}-${var.environment}"
  image_tag_mutability = "MUTABLE"
  
  # Enable automatic image scanning for vulnerabilities
  image_scanning_configuration { 
    scan_on_push = true 
  }
  
  tags = { Name = "${var.project}-${var.environment}-ecr" }
}
