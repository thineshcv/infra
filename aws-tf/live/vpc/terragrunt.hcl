include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../modules/vpc"
}

inputs = {
  name = "my-vpc"
  cidr_block = "10.0.0.0/20"

  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Environment = "production"
    Owner = "my-team"
  }
}
