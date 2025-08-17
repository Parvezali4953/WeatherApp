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

# --- ECS Services (Blue & Green) ---
resource "aws_ecs_service" "blue" {
  name            = "weather-app-blue-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    # Now using both private subnets for high availability
    subnets          = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_groups  = [aws_security_group.app_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.blue_tg.arn
    container_name   = "weather-app"
    container_port   = 5000
  }
}

resource "aws_ecs_service" "green" {
  name            = "weather-app-green-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  launch_type     = "FARGATE"
  desired_count   = 0

  network_configuration {
    # Now using both private subnets for high availability
    subnets          = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_groups  = [aws_security_group.app_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.green_tg.arn
    container_name   = "weather-app"
    container_port   = 5000
  }
}