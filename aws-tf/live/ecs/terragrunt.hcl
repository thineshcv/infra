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
    security_group_id = "sg-mock-external"
  }
}

dependency "internal_alb" {
  config_path = "../internal-alb"

  mock_outputs = {
    target_group_arns = {
      "svc-a" = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/mock-a/1234567890"
      "svc-b" = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/mock-b/1234567890"
    }
    security_group_id = "sg-mock-internal"
    alb_dns_name      = "internal-mock.us-east-1.elb.amazonaws.com"
  }
}

dependency "app_config" {
  config_path = "../app-config"

  mock_outputs = {
    ssm_parameter_arns = {
      "LOG_LEVEL"      = "arn:aws:ssm:us-east-1:123456789012:parameter/play-cluster/LOG_LEVEL"
      "FEATURE_NEW_UI" = "arn:aws:ssm:us-east-1:123456789012:parameter/play-cluster/FEATURE_NEW_UI"
    }
    secret_arns = {
      "DB_PASSWORD" = "arn:aws:secretsmanager:us-east-1:123456789012:secret:play-cluster/DB_PASSWORD-AbCdEf"
      "API_KEY"     = "arn:aws:secretsmanager:us-east-1:123456789012:secret:play-cluster/API_KEY-AbCdEf"
    }
  }
}

inputs = {
  cluster_name = "play-cluster"

  services = {
    # Service A: internet-facing (external ALB) + internal ALB
    "service-a" = {
      container_name  = "nginx"
      container_image = "nginx:latest"
      container_port  = 80
      task_cpu        = 256
      task_memory     = 512
      desired_count   = 2
      target_group_arns = [
        dependency.lb.outputs.target_group_arn,
        dependency.internal_alb.outputs.target_group_arns["svc-a"],
      ]
      environment = {
        INTERNAL_LB_URL = "http://${dependency.internal_alb.outputs.alb_dns_name}"
      }
      secrets = {
        DB_PASSWORD = dependency.app_config.outputs.secret_arns["DB_PASSWORD"]
        API_KEY     = dependency.app_config.outputs.secret_arns["API_KEY"]
        LOG_LEVEL   = dependency.app_config.outputs.ssm_parameter_arns["LOG_LEVEL"]
      }
    }

    # Service B: internal only
    "service-b" = {
      container_name  = "httpd"
      container_image = "httpd:latest"
      container_port  = 80
      task_cpu        = 256
      task_memory     = 512
      desired_count   = 2
      target_group_arns = [
        dependency.internal_alb.outputs.target_group_arns["svc-b"],
      ]
      environment = {
        INTERNAL_LB_URL = "http://${dependency.internal_alb.outputs.alb_dns_name}"
      }
      secrets = {
        DB_PASSWORD = dependency.app_config.outputs.secret_arns["DB_PASSWORD"]
        LOG_LEVEL   = dependency.app_config.outputs.ssm_parameter_arns["LOG_LEVEL"]
      }
    }
  }

  vpc_id             = dependency.vpc.outputs.vpc_id
  private_subnet_ids = dependency.subnet.outputs.private_subnet_ids

  # SG IDs from both ALBs so ECS tasks accept traffic from each
  alb_security_group_ids = [
    dependency.lb.outputs.security_group_id,
    dependency.internal_alb.outputs.security_group_id,
  ]

  aws_region = "us-east-1"

  tags = {
    Environment = "play"
    ManagedBy   = "terragrunt"
  }
}
