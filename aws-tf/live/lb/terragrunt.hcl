include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../modules/lb"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id         = "vpc-123341"
    vpc_cidr_block = "10.0.0.0/16"
  }
}

dependency "subnet" {
  config_path = "../subnet/"

  mock_outputs = {
    private_subnet_ids = ["abc", "def", "ghi"]
    public_subnet_ids  = ["abc1", "def1", "ghi1"]
  }
}

inputs = {
  name               = "front-end-alb"
  vpc_id             = dependency.vpc.outputs.vpc_id
  public_subnet_ids  = dependency.subnet.outputs.public_subnet_ids
  private_subnet_ids = dependency.subnet.outputs.private_subnet_ids
  enable_https       = false  # flip to true when you have an ACM certificate

  # Uncomment when you have a domain + ACM cert:
  # ssl_policy          = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  # ssl_certificate_arn = dependency.acm.outputs.certificate_arn
}
