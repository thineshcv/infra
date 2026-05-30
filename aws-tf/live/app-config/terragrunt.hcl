include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../modules/app-config"
}

inputs = {
  project = "play-cluster"

  # --- Plain config (SSM Parameter Store – free tier) ---
  ssm_parameters = {
    "LOG_LEVEL" = {
      value       = "info"
      description = "Application log level"
    }
    "FEATURE_NEW_UI" = {
      value       = "true"
      description = "Feature flag – new UI"
    }
  }

  # --- Sensitive values (Secrets Manager – encrypted, rotatable) ---
  secrets = {
    "DB_PASSWORD" = {
      description = "RDS master password"
    }
    "API_KEY" = {
      description = "Third-party API key"
    }
  }

  # Actual secret values – kept separate so Terraform can iterate over keys
  secret_values = {
    "DB_PASSWORD" = "CHANGE_ME_BEFORE_APPLY"
    "API_KEY"     = "CHANGE_ME_BEFORE_APPLY"
  }

  tags = {
    Environment = "play"
    ManagedBy   = "terragrunt"
  }
}
