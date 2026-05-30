include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../modules/subnet"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id = "vpc-123341"
  }
}

inputs = {
  vpc_id = dependency.vpc.outputs.vpc_id
  az = ["us-east-1a", "us-east-1b", "us-east-1c" ]
  private_cidr = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_cidr =["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}
