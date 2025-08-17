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

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_policy" "secrets_access" {
  name        = "weather-app-secrets-access"
  path        = "/"
  description = "IAM policy for the weather application to access secrets"

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

resource "aws_iam_role_policy_attachment" "ecs_task_secrets" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.secrets_access.arn
}

resource "aws_iam_role_policy_attachment" "ecs_execution_secrets" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.secrets_access.arn
}

resource "aws_iam_policy" "cloudwatch_metrics" {
  name        = "weather-app-cloudwatch-metrics"
  path        = "/"
  description = "IAM policy to allow the application to send metrics to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "cloudwatch:PutMetricData"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_cloudwatch" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.cloudwatch_metrics.arn
}

resource "aws_iam_role" "github_actions" {
  name = "GitHubActionsRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
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
      }
    ]
  })
  tags = {
    Application = "weather-app"
    Environment = "ci-cd"
  }
  description = "Role for GitHub Actions to deploy the WeatherApp to AWS"
}

resource "aws_iam_policy" "github_actions_policy" {
  name = "GitHubActionsPolicy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
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
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:${var.aws_account_id}:log-group:/aws/ecs/weather-app*:*"
      },
      # Comprehensive permissions for Terraform to create, describe, modify and tag resources
      {
        Effect = "Allow",
        Action = [
          "iam:CreateRole",
          "iam:CreatePolicy",
          "iam:AttachRolePolicy",
          "iam:TagRole",
          "iam:TagPolicy",
          "ec2:CreateVpc",
          "ec2:CreateSubnet",
          "ec2:CreateInternetGateway",
          "ec2:CreateRouteTable",
          "ec2:CreateRoute",
          "ec2:CreateNatGateway",
          "ec2:AssociateRouteTable",
          "ec2:AllocateAddress",
          "ec2:CreateSecurityGroup",
          "ec2:CreateTags",
          "ec2:ModifyVpcAttribute", # NEW: VPC modification permission
          "ecr:CreateRepository",
          "ecs:CreateCluster",
          "logs:CreateLogGroup",
          "secretsmanager:CreateSecret",
          "secretsmanager:TagResource",
          "elbv2:CreateLoadBalancer",
          "elbv2:CreateTargetGroup",
          "elbv2:CreateListener",
          "elbv2:CreateRule",
          "elbv2:AddTags"
        ],
        Resource = "*"
      },
      # Permissions for Terraform to read existing resources and describe their attributes
      {
        Effect = "Allow",
        Action = [
          "iam:ListOpenIDConnectProviders",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeAddresses",
          "ec2:DescribeAddressesAttribute", # NEW: Elastic IP description permission
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeRouteTables",
          "ec2:DescribeNatGateways",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeTags",
          "ecr:DescribeRepositories",
          "ecs:DescribeClusters",
          "ecs:DescribeServices",
          "ecs:UpdateService",
          "logs:DescribeLogGroups",
          "secretsmanager:DescribeSecret",
          "elbv2:Describe*",
          "elbv2:ModifyListener",
          "iam:GetRole",
          "iam:ListPolicies"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_attach" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_policy.arn
}