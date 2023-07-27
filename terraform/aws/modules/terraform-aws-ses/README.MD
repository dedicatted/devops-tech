## Needs clarification regarding var.domain, we can create a public hosted zone manually for our tests
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.9.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_access_key.ses](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key) | resource |
| [aws_iam_group.ses_users](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group) | resource |
| [aws_iam_group_policy.ses_group_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy) | resource |
| [aws_iam_user.ses](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_group_membership.ses_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_group_membership) | resource |
| [aws_iam_user_policy.sending_emails](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy) | resource |
| [aws_route53_record.amazonses_dkim_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.amazonses_verification_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_ses_domain_dkim.ses_domain_dkim](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_domain_dkim) | resource |
| [aws_ses_domain_identity.ses_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_domain_identity) | resource |
| [aws_iam_policy_document.ses_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_route53_zone.zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain"></a> [domain](#input\_domain) | Should be pre-created by client?! | `any` | n/a | yes |
| <a name="input_iam_allowed_resources"></a> [iam\_allowed\_resources](#input\_iam\_allowed\_resources) | n/a | `list` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | `"app"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ses_iam_access_key"></a> [ses\_iam\_access\_key](#output\_ses\_iam\_access\_key) | n/a |
| <a name="output_ses_iam_secret_key"></a> [ses\_iam\_secret\_key](#output\_ses\_iam\_secret\_key) | n/a |
| <a name="output_ses_iam_smtp_password"></a> [ses\_iam\_smtp\_password](#output\_ses\_iam\_smtp\_password) | n/a |
