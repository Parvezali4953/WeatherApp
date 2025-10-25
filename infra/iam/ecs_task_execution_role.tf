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

# The Execution Role is now strictly limited to ECR/CloudWatch.
