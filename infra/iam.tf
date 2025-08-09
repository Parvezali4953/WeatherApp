# Execution Role (for ECS agent)
resource "aws_iam_role" "ecs_execution_role" {
  name               = "weather-app-execution-role"
  description        = "Allows ECS tasks to call AWS services on your behalf"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  tags = {
    Application = "weather-app"
    Environment = "production"
  }
}

# Task Role (for your application)
resource "aws_iam_role" "ecs_task_role" {
  name               = "weather-app-task-role"
  description        = "Provides permissions for the weather application to access AWS resources"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  tags = {
    Application = "weather-app"
    Environment = "production"
  }
}

# Attach standard ECS policies
resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Custom secret access policy (least privilege)
resource "aws_iam_role_policy" "secrets_access" {
  name   = "weather-app-secrets-access"
  role   = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Action    = ["secretsmanager:GetSecretValue"],
      Resource  = [aws_secretsmanager_secret.api_key.arn]
      Condition = {
        StringEquals = {
          "secretsmanager:ResourceTag/Application" = "weather-app"
        }
      }
    }]
  })
}

# GitHub Actions Role for CI/CD
resource "aws_iam_role" "github_actions" {
  name        = "WeatherAppGitHubActionsRole"
  description = "Allows GitHub Actions to deploy to ECS"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = "arn:aws:iam::${var.aws_account_id}:oidc-provider/token.actions.githubusercontent.com"
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        },
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:*"
        }
      }
    }]
  })

  tags = {
    Application = "weather-app"
    Environment = "ci-cd"
  }
}

# Custom policy for GitHub Actions (more secure than full access)
resource "aws_iam_role_policy" "github_actions_ecs" {
  name = "GitHubActionsECSPolicy"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecs:RegisterTaskDefinition",
          "ecs:DeregisterTaskDefinition",
          "ecs:ListClusters",
          "ecs:DescribeClusters",
          "ecs:ListTaskDefinitions",
          "ecs:DescribeTaskDefinition",
          "ecs:UpdateService",
          "ecs:DescribeServices"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "iam:PassRole"
        ],
        Resource = [
          aws_iam_role.ecs_execution_role.arn,
          aws_iam_role.ecs_task_role.arn
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:${var.aws_account_id}:log-group:/aws/ecs/weather-app*:*"
      }
    ]
  })
}