variable "cidr_block" {
  type        = string
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}


variable "name" {
  type        = string
  description = "The name for the VPC"
  default     = "my-vpc"
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "Whether to enable DNS hostnames for the VPC"
  default     = true
}

variable "enable_dns_support" {
  type        = bool
  description = "Whether to enable DNS support for the VPC"
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the VPC"
  default     = {}
}
