output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = [for k, s in aws_subnet.private : s.id]
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = [for k, s in aws_subnet.public : s.id]
}
