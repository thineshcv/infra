include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../modules/ecs"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id = "vpc-mock"
  }
}

dependency "subnet" {
  config_path = "../subnet"

  mock_outputs = {
    private_subnet_ids = ["subnet-mock-1", "subnet-mock-2"]
  }
}

dependency "lb" {
  config_path = "../lb"

  mock_outputs = {
    target_group_arn  = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/mock/1234567890"
    security_group_id = "sg-mock"
  }
}

inputs = {
  cluster_name          = "play-cluster"
  service_name          = "nginx-test"
  container_name        = "nginx"
  container_image       = "nginx:latest"
  container_port        = 80
  task_cpu              = 256
  task_memory           = 512
  desired_count         = 2
  vpc_id                = dependency.vpc.outputs.vpc_id
  private_subnet_ids    = dependency.subnet.outputs.private_subnet_ids
  target_group_arn      = dependency.lb.outputs.target_group_arn
  alb_security_group_id = dependency.lb.outputs.security_group_id
  aws_region            = "us-east-1"

  tags = {
    Environment = "play"
    ManagedBy   = "terragrunt"
  }
}
