variable "name" {
  type        = string
  description = "Name for the internal ALB"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "vpc_cidr_block" {
  type        = string
  description = "VPC CIDR block – used for security group ingress so ECS tasks can reach the ALB"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs where the internal ALB is placed"
}

variable "services" {
  type = map(object({
    port              = number
    path_patterns     = list(string)
    health_check_path = string
    priority          = number
  }))
  description = "Map of service name to routing configuration. Each entry creates a target group and a path-based listener rule."
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}
