module "secrets_manager" {
  source = "github.com/itsyndicate/terraform-aws-secrets-manager//."

  secret_name = var.secrets_manager_secret_name
  secret_keys = var.secrets_manager_secret_keys
}
