output "alb_arn" {
  description = "ARN of the internal ALB"
  value       = aws_lb.internal.arn
}

output "alb_dns_name" {
  description = "DNS name of the internal ALB – use this as the base URL for inter-service calls"
  value       = aws_lb.internal.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the internal ALB"
  value       = aws_lb.internal.zone_id
}

output "target_group_arns" {
  description = "Map of service name → target group ARN"
  value       = { for k, tg in aws_lb_target_group.services : k => tg.arn }
}

output "security_group_id" {
  description = "ID of the internal ALB security group"
  value       = aws_security_group.internal_lb.id
}
