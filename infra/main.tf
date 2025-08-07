provider "aws" {
  region = var.region
}

resource "aws_secretsmanager_secret" "api_key" {
  name = "weather-api-key"
}

resource "aws_secretsmanager_secret_version" "api_key_version" {
  secret_id     = aws_secretsmanager_secret.api_key.id
  secret_string = var.api_key
}

resource "aws_ecr_repository" "app_repo" {
  name = "weather-app"
}

resource "aws_ecs_cluster" "app_cluster" {
  name = "weather-app-cluster"
}

resource "aws_ecs_task_definition" "app_task" {
  family                   = "weather-app-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256    # Free tier eligible
  memory                   = 512    # Free tier eligible
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([{
    name      = "weather-app",
    image     = "${aws_ecr_repository.app_repo.repository_url}:latest",
    essential = true,
    portMappings = [{
      containerPort = 5000,
      hostPort      = 5000
    }],
    environment = [
      { name = "AWS_REGION", value = var.region }
    ]
  }])
}

resource "aws_ecs_service" "app_service" {
  name            = "weather-app-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1  # Free tier: 1 task always running

  network_configuration {
    subnets          = [aws_default_subnet.default_subnet.id]
    security_groups  = [aws_security_group.app_sg.id]
    assign_public_ip = true
  }
}

resource "aws_default_vpc" "default_vpc" {}

resource "aws_default_subnet" "default_subnet" {
  availability_zone = "${var.region}a"
}

resource "aws_security_group" "app_sg" {
  name   = "weather-app-sg"
  vpc_id = aws_default_vpc.default_vpc.id

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}