variable "project" {
  type        = string
  description = "Project or app name – used as a prefix for all parameter/secret names"
}

variable "ssm_parameters" {
  type = map(object({
    value       = string
    description = optional(string, "")
    type        = optional(string, "String") # "String" or "SecureString"
  }))
  description = <<-EOT
    Non-sensitive (or lightly-sensitive) config stored in SSM Parameter Store.
    Use type = "SecureString" for values that should be KMS-encrypted at rest.
    Each key becomes the parameter name: /<project>/<key>
  EOT
  default     = {}
}

variable "secrets" {
  type = map(object({
    description = optional(string, "")
  }))
  description = <<-EOT
    Secret metadata stored in AWS Secrets Manager.
    Each key becomes the secret name: <project>/<key>.
    Actual secret values are provided separately via `secret_values` to keep keys non-sensitive.
  EOT
  default     = {}
}

variable "secret_values" {
  type        = map(string)
  description = "Map of secret key → secret value. Keys must match entries in `secrets`."
  default     = {}
  sensitive   = true
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}
