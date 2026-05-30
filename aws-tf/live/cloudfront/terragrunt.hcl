include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../modules/cloudfront"
}

dependency "lb" {
  config_path = "../lb"

  mock_outputs = {
    alb_dns_name = "mock-alb-123.us-east-1.elb.amazonaws.com"
  }
}

inputs = {
  bucket_name       = "play-infra-frontend-717056863763"
  alb_dns_name      = dependency.lb.outputs.alb_dns_name
  enable_cloudfront = false  # flip to true once AWS account is verified for CloudFront
  comment           = "Play infra - static frontend"
  price_class       = "PriceClass_100"

  tags = {
    Environment = "play"
    ManagedBy   = "terragrunt"
  }
}
