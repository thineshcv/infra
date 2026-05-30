variable "cluster_name" {
  type        = string
  description = "Name of the ECS cluster"
}

variable "service_name" {
  type        = string
  description = "Name of the ECS service"
}

variable "container_name" {
  type        = string
  description = "Name of the container"
  default     = "app"
}

variable "container_image" {
  type        = string
  description = "Docker image to run (e.g. nginx:latest)"
  default     = "nginx:latest"
}

variable "container_port" {
  type        = number
  description = "Port the container listens on"
  default     = 80
}

variable "task_cpu" {
  type        = number
  description = "CPU units for the task (256 = 0.25 vCPU)"
  default     = 256
}

variable "task_memory" {
  type        = number
  description = "Memory in MiB for the task"
  default     = 512
}

variable "desired_count" {
  type        = number
  description = "Number of task instances"
  default     = 2
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for the ECS security group"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs where Fargate tasks run"
}

variable "target_group_arn" {
  type        = string
  description = "ARN of the ALB target group to register tasks with"
}

variable "alb_security_group_id" {
  type        = string
  description = "Security group ID of the ALB (for ingress rules)"
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
