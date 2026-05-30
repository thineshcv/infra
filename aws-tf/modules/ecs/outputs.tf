output "cluster_id" {
  description = "ID of the ECS cluster"
  value       = aws_ecs_cluster.this.id
}

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.this.name
}

output "service_names" {
  description = "Map of service key → ECS service name"
  value       = { for k, s in aws_ecs_service.services : k => s.name }
}

output "task_definition_arns" {
  description = "Map of service key → task definition ARN"
  value       = { for k, td in aws_ecs_task_definition.services : k => td.arn }
}

output "ecs_security_group_id" {
  description = "ID of the shared ECS tasks security group"
  value       = aws_security_group.ecs_tasks.id
}
