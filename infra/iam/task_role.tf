data "aws_iam_policy_document" "task_assume" {
  statement {
    effect = "Allow"
    principals { 
      type = "Service" 
      identifiers = ["ecs-tasks.amazonaws.com"] 
    }
    actions = ["sts:AssumeRole"]
  }
}

# The Task Role (aws_iam_role.task) is what the running container assumes.
# This role runs the application code inside the container.
resource "aws_iam_role" "task" {
  name               = "${var.project}-${var.environment}-ecs-task"
  assume_role_policy = data.aws_iam_policy_document.task_assume.json
  tags = { Name = "${var.project}-${var.environment}-ecs-task" }
}
