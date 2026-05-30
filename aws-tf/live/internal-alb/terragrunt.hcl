include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../modules/internal-alb"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id         = "vpc-mock"
    vpc_cidr_block = "10.0.0.0/16"
  }
}

dependency "subnet" {
  config_path = "../subnet"

  mock_outputs = {
    private_subnet_ids = ["subnet-mock-1", "subnet-mock-2"]
  }
}

inputs = {
  name               = "internal-alb"
  vpc_id             = dependency.vpc.outputs.vpc_id
  vpc_cidr_block     = dependency.vpc.outputs.vpc_cidr_block
  private_subnet_ids = dependency.subnet.outputs.private_subnet_ids

  # Each entry creates a target group + path-based listener rule.
  # Services reach each other at: http://<internal-alb-dns>/service-a/...
  services = {
    "svc-a" = {
      port              = 80
      path_patterns     = ["/service-a", "/service-a/*"]
      health_check_path = "/"
      priority          = 100
    }
    "svc-b" = {
      port              = 80
      path_patterns     = ["/service-b", "/service-b/*"]
      health_check_path = "/"
      priority          = 200
    }
  }

  tags = {
    Environment = "play"
    ManagedBy   = "terragrunt"
  }
}
