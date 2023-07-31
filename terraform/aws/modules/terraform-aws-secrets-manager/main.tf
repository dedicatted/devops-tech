resource "aws_secretsmanager_secret" "key" {
  for_each   = var.key_secret
  name       = each.key
  kms_key_id = var.kms_key_arn
}

resource "aws_secretsmanager_secret_version" "value" {
  for_each      = var.key_secret
  secret_id     = aws_secretsmanager_secret.key[each.key].id
  secret_string = each.value
}
