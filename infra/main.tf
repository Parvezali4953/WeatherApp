provider "aws" {
  region = var.region
}

# --- AWS Secrets Manager ---
resource "aws_secretsmanager_secret" "api_key" {
  name        = "weather-api-key"
  description = "OpenWeather API Key"
}

resource "aws_secretsmanager_secret_version" "api_key_version" {
  secret_id     = aws_secretsmanager_secret.api_key.id
  secret_string = var.api_key
}

# --- ECR Repository ---
resource "aws_ecr_repository" "app_repo" {
  name                 = "weather-app"
  image_tag_mutability = "MUTABLE"
}

# --- ECS Cluster & Task Definition ---
resource "aws_ecs_cluster" "app_cluster" {
  name = "weather-app-cluster"
}

resource "aws_ecs_task_definition" "app_task" {
  family                   = "weather-app-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([{
    name      = "weather-app",
    image     = "${aws_ecr_repository.app_repo.repository_url}:latest",
    essential = true,
    portMappings = [{
      containerPort = 5000,
      hostPort      = 5000
    }],
    secrets = [{
      name      = "API_KEY",
      valueFrom = aws_secretsmanager_secret.api_key.arn
    }],
    logConfiguration = {
      logDriver = "awslogs",
      options = {
        "awslogs-group"         = "/ecs/weather-app",
        "awslogs-region"        = var.region,
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
}

# --- CloudWatch Log Group ---
resource "aws_cloudwatch_log_group" "app_logs" {
  name = "/ecs/weather-app"
}

# --- Application Load Balancer ---
resource "aws_lb" "app_lb" {
  name               = "weather-app-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_default_subnet.default_subnet_a.id, aws_default_subnet.default_subnet_b.id]
  security_groups    = [aws_security_group.lb_sg.id]
}

resource "aws_lb_target_group" "app_tg" {
  name        = "weather-app-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = aws_default_vpc.default_vpc.id
  target_type = "ip"

  health_check {
    path = "/health"
    protocol = "HTTP"
    matcher  = "200"
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# --- ECS Service ---
resource "aws_ecs_service" "app_service" {
  name            = "weather-app-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = [aws_default_subnet.default_subnet_a.id, aws_default_subnet.default_subnet_b.id]
    security_groups  = [aws_security_group.app_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = "weather-app"
    container_port   = 5000
  }
}

# --- Default VPC and Subnets ---
resource "aws_default_vpc" "default_vpc" {}

resource "aws_default_subnet" "default_subnet_a" {
  availability_zone = "${var.region}a"
}

resource "aws_default_subnet" "default_subnet_b" {
  availability_zone = "${var.region}b"
}

# --- Security Groups ---
resource "aws_security_group" "lb_sg" {
  name        = "weather-app-lb-sg"
  description = "Allow HTTP traffic to the ALB"
  vpc_id      = aws_default_vpc.default_vpc.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
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

resource "aws_security_group" "app_sg" {
  name        = "weather-app-sg"
  description = "Allow traffic from the ALB only"
  vpc_id      = aws_default_vpc.default_vpc.id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}