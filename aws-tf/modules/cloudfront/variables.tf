variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket for the frontend"
}

variable "alb_dns_name" {
  type        = string
  description = "DNS name of the ALB for the API backend origin"
}

variable "comment" {
  type        = string
  description = "Comment for the CloudFront distribution"
  default     = "Frontend static site distribution"
}

variable "price_class" {
  type        = string
  description = "CloudFront price class"
  default     = "PriceClass_100"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}

variable "enable_cloudfront" {
  type        = bool
  description = "Enable CloudFront distribution (requires account verification). When false, S3 website hosting is used instead."
  default     = true
}
