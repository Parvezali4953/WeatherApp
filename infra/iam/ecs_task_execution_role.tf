data "aws_iam_policy_document" "assume" {
  statement {
    effect = "Allow"
    principals { 
      type = "Service" 
      identifiers = ["ecs-tasks.amazonaws.com"] 
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "execution" {
  name               = "${var.project}-${var.environment}-ecs-exec"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

resource "aws_iam_role_policy_attachment" "exec_policy" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# inline permission to read the secret from Secrets Manager
data "aws_iam_policy_document" "exec_read_secret" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = [var.weather_api_secret_arn]
  }
}

resource "aws_iam_role_policy" "exec_read_secret" {
  name   = "${var.project}-${var.environment}-exec-read-secret"
  role   = aws_iam_role.execution.id
  policy = data.aws_iam_policy_document.exec_read_secret.json
}
