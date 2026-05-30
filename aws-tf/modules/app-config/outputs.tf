output "ssm_parameter_arns" {
  description = "Map of parameter key → ARN (use these in ECS task definition secrets)"
  value       = { for k, p in aws_ssm_parameter.this : k => p.arn }
}

output "ssm_parameter_names" {
  description = "Map of parameter key → full name (e.g. /<project>/<key>)"
  value       = { for k, p in aws_ssm_parameter.this : k => p.name }
}

output "secret_arns" {
  description = "Map of secret key → ARN (use these in ECS task definition secrets)"
  value       = { for k, s in aws_secretsmanager_secret.this : k => s.arn }
}

output "secret_names" {
  description = "Map of secret key → full name"
  value       = { for k, s in aws_secretsmanager_secret.this : k => s.name }
}
