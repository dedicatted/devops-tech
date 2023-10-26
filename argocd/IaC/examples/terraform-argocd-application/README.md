## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_argocd"></a> [argocd](#requirement\_argocd) | 5.6.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_argocd"></a> [argocd](#provider\_argocd) | 5.6.0 |
| <a name="provider_github"></a> [github](#provider\_github) | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [argocd_application.application](https://registry.terraform.io/providers/oboukili/argocd/5.6.0/docs/resources/application) | resource |
| [argocd_application.appofapp](https://registry.terraform.io/providers/oboukili/argocd/5.6.0/docs/resources/application) | resource |
| [argocd_project.argocd_project](https://registry.terraform.io/providers/oboukili/argocd/5.6.0/docs/resources/project) | resource |
| [github_repository_file.application](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_file) | resource |
| [github_repository_file.file](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_file) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_argocd_repo_name"></a> [argocd\_repo\_name](#input\_argocd\_repo\_name) | n/a | `string` | `"argocd"` | no |
| <a name="input_argocd_repo_url"></a> [argocd\_repo\_url](#input\_argocd\_repo\_url) | n/a | `string` | `"git@github.com:diligend/argocd.git"` | no |
| <a name="input_cluster_endpoint"></a> [cluster\_endpoint](#input\_cluster\_endpoint) | n/a | `any` | n/a | yes |
| <a name="input_cluster_list"></a> [cluster\_list](#input\_cluster\_list) | n/a | `any` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | `"develop"` | yes |

## Outputs

No outputs.
