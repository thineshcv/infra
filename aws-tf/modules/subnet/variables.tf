variable "vpc_id" {
  type        = string
  description = "vpc id for subnets"
}

variable "private_cidr" {
  type        = list(string)
  description = "subnet cidr block"
}

variable "public_cidr" {
  type        = list(string)
  description = "subnet cidr block"
}


variable "az" {
  type        = list(string)
  description = "subnets availability zone"
}
