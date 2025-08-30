resource "aws_ecs_service" "this" {
  name            = "${var.project}-${var.environment}-svc"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.public_subnet_ids
    security_groups  = [var.cluster_sg_id]
    assign_public_ip = var.assign_public_ip
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = local.container_name
    container_port   = var.container_port
  }

  deployment_controller { type = "ECS" }
  deployment_circuit_breaker { 
    enable = true 
    rollback = true 
  }
}

