locals { container_name = "${var.project}-container" }

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.project}-${var.environment}-task"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  
  # Execution Role: Only for ECR pull and CloudWatch logs.
  execution_role_arn       = var.execution_role_arn 
  
  # CRITICAL: New Task Role. Only for reading Secrets Manager (App's actual permissions).
  task_role_arn            = var.task_role_arn 

  container_definitions = jsonencode([
    {
      name      = local.container_name
      image     = var.container_image
      essential = true
      portMappings = [{ containerPort = var.container_port, protocol = "tcp" }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = var.log_group_name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
      # Secrets are read using the dedicated Task Role (task_role_arn)
      secrets = [
        {
          name      = "API_KEY"
          valueFrom = var.weather_api_secret_arn
        }
      ]
    }
  ])
}
