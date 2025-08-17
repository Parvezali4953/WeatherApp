# --- Auto Scaling ---
resource "aws_appautoscaling_target" "ecs_target_blue" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.app_cluster.name}/${aws_ecs_service.blue.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.min_capacity
  max_capacity       = var.max_capacity
}

resource "aws_appautoscaling_policy" "scale_out_blue" {
  name               = "cpu-utilization-scale-out-blue"
  policy_type        = "TargetTrackingScaling"
  service_namespace  = "ecs"
  resource_id        = aws_appautoscaling_target.ecs_target_blue.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target_blue.scalable_dimension

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = var.cpu_utilization_target
    scale_out_cooldown = 300
    scale_in_cooldown  = 300
  }
}