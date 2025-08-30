data "aws_caller_identity" "current" {}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

data "aws_iam_policy_document" "gh_oidc_trust" {
  statement {
    effect = "Allow"
    principals { 
        type = "Federated" 
        identifiers = [aws_iam_openid_connect_provider.github.arn] 
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:Parvezali4953/WeatherApp:ref:refs/heads/main"]
    }
  }
}

resource "aws_iam_role" "gh_actions" {
  name               = "${var.project}-${var.environment}-gh-oidc"
  assume_role_policy = data.aws_iam_policy_document.gh_oidc_trust.json
}

data "aws_iam_policy_document" "gh_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken","ecr:BatchCheckLayerAvailability","ecr:BatchGetImage",
      "ecr:CompleteLayerUpload","ecr:DescribeRepositories","ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload","ecr:PutImage","ecr:UploadLayerPart"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ecs:*","elasticloadbalancing:Describe*","logs:DescribeLogGroups",
      "cloudwatch:DescribeAlarms","iam:PassRole","ssm:GetParameters","ssm:GetParameter","sts:GetCallerIdentity"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = ["s3:GetObject","s3:PutObject","s3:ListBucket"]
    resources = [
      "arn:aws:s3:::weather-prod-tf-state-123456789012",
      "arn:aws:s3:::weather-prod-tf-state-123456789012/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = ["dynamodb:GetItem","dynamodb:PutItem","dynamodb:DeleteItem","dynamodb:DescribeTable"]
    resources = ["arn:aws:dynamodb:*:*:table/weather-prod-tf-lock"]
  }
}

resource "aws_iam_role_policy" "gh_inline" {
  name   = "${var.project}-${var.environment}-gh-inline"
  role   = aws_iam_role.gh_actions.id
  policy = data.aws_iam_policy_document.gh_policy.json
}
