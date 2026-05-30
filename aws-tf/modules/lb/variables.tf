variable "name" {
  type        = string
  description = "lb name"
}

variable "vpc_id" {
  type        = string
  description = "vpc id for the load balancer"
}

variable "lb_description" {
  type        = string
  description = "description for the load balancer security group"
  default     = "value"
}

variable "tags" {
  type        = map(string)
  description = "tags for the load balancer security group"
  default     = {}
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "private subnet ids for private route table association"
  default     = []
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "public subnet ids for the load balancer"
}


variable "ssl_policy" {
  type        = string
  description = "ssl policy lb listener"
  default     = null
}

variable "ssl_certificate_arn" {
  type        = string
  description = "arn to ssl cert"
  default     = null
}

variable "enable_https" {
  type        = bool
  description = "enable HTTPS listener (requires ssl_certificate_arn and ssl_policy)"
  default     = false
}
