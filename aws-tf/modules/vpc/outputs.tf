output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "vpc_instance_tenancy" {
  description = "Instance tenancy of the VPC"
  value       = aws_vpc.main.instance_tenancy
}

output "vpc_tags" {
  description = "Tags applied to the VPC"
  value       = aws_vpc.main.tags
}
