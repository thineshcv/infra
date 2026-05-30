# --- SSM Parameter Store (app config, feature flags, URLs) ---
resource "aws_ssm_parameter" "this" {
  for_each = var.ssm_parameters

  name        = "/${var.project}/${each.key}"
  type        = each.value.type
  value       = each.value.value
  description = each.value.description

  tags = merge(var.tags, {
    Name = "/${var.project}/${each.key}"
  })
}

# --- Secrets Manager (DB creds, API keys, tokens) ---
resource "aws_secretsmanager_secret" "this" {
  for_each = var.secrets

  name        = "${var.project}/${each.key}"
  description = each.value.description

  tags = merge(var.tags, {
    Name = "${var.project}/${each.key}"
  })
}

resource "aws_secretsmanager_secret_version" "this" {
  for_each = var.secrets

  secret_id     = aws_secretsmanager_secret.this[each.key].id
  secret_string = var.secret_values[each.key]
}
