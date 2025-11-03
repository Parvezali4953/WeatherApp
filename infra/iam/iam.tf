# 1. ECS Task Execution Role
# PURPOSE: Grants the AWS ECS service permissions to manage the task on our behalf.
#          This is NOT for application code.
#
# REQUIRED PERMISSIONS:
#   - ecr:GetAuthorizationToken
#   - ecr:BatchCheckLayerAvailability
#   - ecr:GetDownloadUrlForLayer
#   - ecr:BatchGetImage
#   - logs:CreateLogStream
#   - logs:PutLogEvents
#
# All these permissions are conveniently bundled in the AWS-managed policy:
# "AmazonECSTaskExecutionRolePolicy".
# Grants permissions to the ECS service to pull images and write logs.

data "aws_iam_policy_document" "ecs_task_execution_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.project_name}-${var.environment}-ecs-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_assume_role.json
  
  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# 2. ECS Task Role
# Grants permissions to the application code inside the container.
# In our case, it needs no permissions, so no policies are attached.

data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_role" {
  name               = "${var.project_name}-${var.environment}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# 4. IAM Policy for Secrets Manager Access
#
# This policy grants the ECS Task Execution Role the specific permission
# it needs to fetch the application's API key from AWS Secrets Manager.
# -----------------------------------------------------------------------------
resource "aws_iam_policy" "secrets_access_policy" {
  name        = "${var.project_name}-${var.environment}-secrets-access-policy"
  description = "Allows access to specific Secrets Manager secrets."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "secretsmanager:GetSecretValue"
        Resource = var.secrets_manager_secret_arn # Grant permission only to this specific secret
      },
    ]
  })
}

# Attach the new secrets policy to the ECS Task Execution Role.
resource "aws_iam_role_policy_attachment" "secrets_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.secrets_access_policy.arn
}