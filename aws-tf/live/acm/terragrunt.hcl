include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../modules/acm"
}

inputs = {
  domain_name               = "example.com"             # TODO: replace with your domain
  subject_alternative_names = ["*.example.com"]          # TODO: adjust SANs as needed
  route53_zone_id           = "ZXXXXXXXXXXXXX"           # TODO: replace with your Route 53 hosted zone ID

  tags = {
    Environment = "production"
    ManagedBy   = "terragrunt"
  }
}
