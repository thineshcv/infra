# --- Auto Scaling targets ---
resource "aws_appautoscaling_target" "ecs" {
  for_each = var.services

  max_capacity       = each.value.autoscaling_max
  min_capacity       = each.value.autoscaling_min
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.services[each.key].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# --- CPU-based target-tracking policy ---
resource "aws_appautoscaling_policy" "ecs_cpu" {
  for_each = var.services

  name               = "${each.key}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs[each.key].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs[each.key].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = each.value.cpu_target_percentage
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}
