variable "domain_name" {
  type        = string
  description = "Primary domain name for the ACM certificate (e.g. example.com)"
}

variable "subject_alternative_names" {
  type        = list(string)
  description = "Additional domain names for the certificate (e.g. [\"*.example.com\"])"
  default     = []
}

variable "route53_zone_id" {
  type        = string
  description = "Route 53 hosted zone ID used for DNS validation"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the certificate"
  default     = {}
}
