# 1. ECS Cluster
#
# A cluster is a logical grouping of tasks or services. Since we are using
# Fargate, we don't need to manage any underlying EC2 instances.
# -----------------------------------------------------------------------------
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}-cluster"

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# -----------------------------------------------------------------------------
# 2. ECS Task Definition
#
# This is the blueprint for our application task. It now uses a template file
# and injects the dynamic ARN values from our IAM module.
# -----------------------------------------------------------------------------
resource "aws_ecs_task_definition" "main" {
  family                   = "${var.project_name}-${var.environment}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory

  execution_role_arn = var.ecs_task_execution_role_arn
  task_role_arn      = var.ecs_task_role_arn

  # Dynamically generate the JSON for the container definition.
  container_definitions = jsonencode([
    {
      name      = "${var.project_name}-container"
      image     = var.container_image
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ],
     
      # This 'secrets' block tells ECS to inject the API key from Secrets Manager
      # into the container as an environment variable named 'API_KEY'.
      secrets = [
        {
          name      = "API_KEY"
          valueFrom = var.secret_arn
        }
      ],
     
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = var.log_group_name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}
# -----------------------------------------------------------------------------
# 3. ECS Service
#
# This resource is responsible for running and maintaining a specified number
# of instances of the task definition. It connects our task to the VPC,
# subnets, and the Application Load Balancer.
# -----------------------------------------------------------------------------
resource "aws_ecs_service" "main" {
  name            = "${var.project_name}-${var.environment}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.min_tasks
  launch_type     = "FARGATE"

  # The network configuration places our tasks in the private subnets.
  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.ecs_sg_id]
  }

  # Connects the service to the Application Load Balancer target group.
  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = "${var.project_name}-container"
    container_port   = var.container_port
  }

  # This ensures that we don't try to destroy the service before the ALB is gone.
  depends_on = [var.alb_listener]
}

# -----------------------------------------------------------------------------
# 4. Autoscaling Configuration
#
# This automatically adjusts the number of tasks running based on CPU load,
# ensuring the application is both cost-effective and highly available.
# -----------------------------------------------------------------------------
# This policy scales the service up or down to keep the average CPU utilization
# at 75%.
resource "aws_appautoscaling_target" "main" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.min_tasks
  max_capacity       = var.max_tasks
}

# This policy scales the service up or down based on CPU utilization.
resource "aws_appautoscaling_policy" "cpu_scaling" {
  name               = "${var.project_name}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.main.resource_id
  scalable_dimension = aws_appautoscaling_target.main.scalable_dimension
  service_namespace  = aws_appautoscaling_target.main.service_namespace

  target_tracking_scaling_policy_configuration {
    # This block explicitly tells Auto Scaling which metric to track.
    # In this case, we are using a standard, predefined metric for the
    # average CPU utilization of the entire ECS service.
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 75 # Keep the average CPU at 75%
    scale_in_cooldown  = 300 # Wait 5 minutes after scaling in before scaling in again.
    scale_out_cooldown = 60  # Wait 1 minute after scaling out before scaling out again.
  }
}
