variable "cluster_name" {
  type        = string
  description = "Name of the ECS cluster"
}

variable "services" {
  type = map(object({
    container_name        = string
    container_image       = string
    container_port        = number
    task_cpu              = number
    task_memory           = number
    desired_count         = number
    target_group_arns     = list(string)
    environment           = optional(map(string), {})
    secrets               = optional(map(string), {})
    autoscaling_min       = optional(number, 1)
    autoscaling_max       = optional(number, 5)
    cpu_target_percentage = optional(number, 70)
  }))
  description = <<-EOT
    Map of ECS services to create on the shared cluster.
    Each key becomes the service / task-definition name.
    `target_group_arns` can contain ARNs from both external and internal ALBs.
    `environment` is an optional map of env vars injected into the container.
    `secrets` is an optional map of env-var-name → SSM/SecretsManager ARN, injected at container start.
  EOT
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for the ECS security group"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs where Fargate tasks run"
}

variable "alb_security_group_ids" {
  type        = list(string)
  description = "Security group IDs of all ALBs (external + internal) that send traffic to ECS tasks"
}

variable "aws_region" {
  type        = string
  description = "AWS region for CloudWatch logs"
  default     = "us-east-1"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}
