resource "aws_ecs_service" "this" {
  name            = "${var.project}-${var.environment}-svc"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"
  
  # CRITICAL: Use Private Subnets. Tasks are now shielded from the public internet.
  network_configuration {
    subnets          = var.private_subnet_ids 
    security_groups  = [var.cluster_sg_id]
    # CRITICAL: Must be FALSE in Private Subnets. Outgoing traffic uses NAT Gateway.
    assign_public_ip = false 
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    # Using the literal name defined by the local block in task_definition.tf
    container_name   = local.container_name
    container_port   = var.container_port
  }

  # Reliability: Deployment Circuit Breaker for automatic rollback on unhealthy deployments.
  deployment_controller { type = "ECS" }
  deployment_circuit_breaker { 
    enable = true 
    rollback = true 
  }

  # Suppress the misleading deprecation warning for assign_public_ip
  lifecycle {
    ignore_changes = [
      network_configuration[0].assign_public_ip,
    ]
  }
}
