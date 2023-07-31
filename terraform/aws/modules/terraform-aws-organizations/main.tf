# Create new aws account
resource "aws_organizations_account" "account" {
  name              = var.name
  email             = var.email
  parent_id         = var.parent_id
  role_name         = var.role_name
  close_on_deletion = true
  lifecycle {
    ignore_changes = [role_name]
  }
}
# Use new provider for new organization
provider "aws" {
  alias = "new_account"
  assume_role {
    role_arn     = "arn:aws:iam::${aws_organizations_account.account.id}:role/${var.role_name}"
    session_name = "account_creation"
  }
}
# Create new user in organization
resource "aws_iam_user" "admin" {
  provider = aws.new_account
  name     = "diligend_tf_admin"
}
# Create console credantials
resource "aws_iam_access_key" "admin" {
  provider = aws.new_account
  user     = aws_iam_user.admin.name
}
# Generate new policy
data "aws_iam_policy_document" "full_admin" {
  provider = aws.new_account
  statement {
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]
  }
}
# Create policy
resource "aws_iam_user_policy" "full" {
  provider = aws.new_account
  name     = "diligent_tf_admin_policy"
  user     = aws_iam_user.admin.name
  policy   = data.aws_iam_policy_document.full_admin.json
}

# SSO part
data "aws_ssoadmin_instances" "example" {}

data "aws_ssoadmin_permission_set" "example" {
  instance_arn = tolist(data.aws_ssoadmin_instances.example.arns)[0]
  name         = "AdministratorAccess"
}

data "aws_identitystore_group" "example" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.example.identity_store_ids)[0]
  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = var.identitystore_group
    }
  }
}

resource "aws_ssoadmin_account_assignment" "example" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.example.arns)[0]
  permission_set_arn = data.aws_ssoadmin_permission_set.example.arn

  principal_id   = data.aws_identitystore_group.example.group_id
  principal_type = "GROUP"

  target_id   = aws_organizations_account.account.id
  target_type = "AWS_ACCOUNT"
}

data "aws_iam_roles" "sso_role" {
  provider   = aws.new_account
  name_regex = "AWSReservedSSO_AdministratorAccess*"
}

# Terraform cloud part 
# Get project id
data "tfe_project" "project" {
  name         = "Dasseti"
  organization = var.organization
}
# Get oauth token
data "tfe_oauth_client" "client" {
  organization     = var.organization
  service_provider = "github"
}
# Get ssh key id
data "tfe_ssh_key" "ssh_key" {
  name         = var.ssh_key_name
  organization = var.organization
}
# Create new workspace
resource "tfe_workspace" "workspace" {
  name                          = var.name
  organization                  = var.organization
  working_directory             = var.workspace_path
  allow_destroy_plan            = false
  terraform_version             = var.tf_version
  structured_run_output_enabled = false
  project_id                    = data.tfe_project.project.id
  ssh_key_id                    = data.tfe_ssh_key.ssh_key.id
  vcs_repo {
    identifier     = var.repo_path
    branch         = "main"
    oauth_token_id = data.tfe_oauth_client.client.oauth_token_id
  }
}
# Create new variable for access key
resource "tfe_variable" "access_key" {
  key          = "AWS_ACCESS_KEY_ID"
  value        = aws_iam_access_key.admin.id
  category     = "env"
  workspace_id = tfe_workspace.workspace.id
  description  = "AWS Access Key"
  sensitive    = true
}
# Create new variable for secret access key
resource "tfe_variable" "secret_key" {
  key          = "AWS_SECRET_ACCESS_KEY"
  value        = aws_iam_access_key.admin.secret
  category     = "env"
  workspace_id = tfe_workspace.workspace.id
  description  = "AWS Secret Key"
  sensitive    = true
}
resource "tfe_variable" "aws_region" {
  key          = "AWS_REGION"
  value        = var.region
  category     = "env"
  workspace_id = tfe_workspace.workspace.id
  description  = "AWS region"
  sensitive    = true
}
resource "tfe_variable" "sso_role_arn" {
  key          = "sso_role_arn"
  value        = replace(one(data.aws_iam_roles.sso_role.arns), "aws-reserved/sso.amazonaws.com/", "")
  category     = "terraform"
  workspace_id = tfe_workspace.workspace.id
  description  = "sso_role_arn"
  sensitive    = true
}
# Route53 Part
# Get Route53 zone ID
data "aws_route53_zone" "root" {
  count = var.root_zone_name == "" ? 0 : 1
  name  = var.root_zone_name
}
# Create new Route53 zone in new account
resource "aws_route53_zone" "zone" {
  provider = aws.new_account
  count    = var.new_zone_name == "" ? 0 : 1
  name     = var.new_zone_name
}
# Create NS Record if need on Root Route53 zone
resource "aws_route53_record" "zone-ns" {
  count      = var.new_zone_name != "" && var.root_zone_name != "" ? 1 : 0
  zone_id    = data.aws_route53_zone.root[0].zone_id
  name       = var.new_zone_name
  type       = "NS"
  ttl        = "30"
  records    = aws_route53_zone.zone[0].name_servers
  depends_on = [data.aws_route53_zone.root]
}
