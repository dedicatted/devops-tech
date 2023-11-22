## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.47 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.6 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | >= 1.7.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 2.0.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.47 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_ebs_csi_driver"></a> [aws\_ebs\_csi\_driver](#module\_aws\_ebs\_csi\_driver) | ./addons/aws-ebs-csi-driver | n/a |
| <a name="module_aws_load_balancer_controller"></a> [aws\_load\_balancer\_controller](#module\_aws\_load\_balancer\_controller) | ./addons/aws-load-balancer-controller | n/a |
| <a name="module_cluster_autoscaler"></a> [cluster\_autoscaler](#module\_cluster\_autoscaler) | ./addons/cluster-autoscaler | n/a |
| <a name="module_external_dns"></a> [external\_dns](#module\_external\_dns) | ./addons/external-dns | n/a |
| <a name="module_external_secrets"></a> [external\_secrets](#module\_external\_secrets) | ./addons/external-secrets | n/a |
| <a name="module_velero"></a> [velero](#module\_velero) | ./addons/velero | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster.eks_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_chart_version"></a> [alb\_chart\_version](#input\_alb\_chart\_version) | ALB controller chart version to use for the ALB controller addons(i.e.: `1.5.4`) | `string` | `"1.5.4"` | no |
| <a name="input_autoscaler_chart_version"></a> [autoscaler\_chart\_version](#input\_autoscaler\_chart\_version) | Cluster autoscaler chart version to use for the cluster autoscaler addons (i.e.: 9.29.1) | `string` | `"9.29.1"` | no |
| <a name="input_aws_ebs_csi_driver"></a> [aws\_ebs\_csi\_driver](#input\_aws\_ebs\_csi\_driver) | Enable ebs csi add-ons | `bool` | `true` | no |
| <a name="input_aws_load_balancer_controller"></a> [aws\_load\_balancer\_controller](#input\_aws\_load\_balancer\_controller) | Enable load balancer controller add-ons | `bool` | `true` | no |
| <a name="input_cluster_autoscaler"></a> [cluster\_autoscaler](#input\_cluster\_autoscaler) | Enable cluster autoscaler add-ons | `bool` | `true` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | AWS EKS cluster name with which terraform works | `string` | n/a | yes |
| <a name="input_ebs_chart_version"></a> [ebs\_chart\_version](#input\_ebs\_chart\_version) | EBS chart version to use for the ebs addons(i.e.: `2.20.0`) | `string` | `"2.20.0"` | no |
| <a name="input_eks_cluster_certificate"></a> [eks\_cluster\_certificate](#input\_eks\_cluster\_certificate) | Cluster certicate which give ability to work with cluster | `string` | n/a | yes |
| <a name="input_eks_cluster_endpoint"></a> [eks\_cluster\_endpoint](#input\_eks\_cluster\_endpoint) | Cluster endpoint which give ability to work with cluster | `string` | n/a | yes |
| <a name="input_external_dns"></a> [external\_dns](#input\_external\_dns) | Enable external dns add-ons | `bool` | `true` | no |
| <a name="input_external_dns_chart_version"></a> [external\_dns\_chart\_version](#input\_external\_dns\_chart\_version) | External DNS chart version to use for the external DNS addons(i.e.: `6.20.4`) | `string` | `"6.20.4"` | no |
| <a name="input_external_secrets"></a> [external\_secrets](#input\_external\_secrets) | Enable external secret add-ons | `bool` | `true` | no |
| <a name="input_external_secrets_chart_version"></a> [external\_secrets\_chart\_version](#input\_external\_secrets\_chart\_version) | External secrets chart version to use for the external secrets addons(i.e.: `0.9.0`) | `string` | `"0.9.0"` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | kms key arn | `string` | n/a | yes |
| <a name="input_oidc_provider_arn"></a> [oidc\_provider\_arn](#input\_oidc\_provider\_arn) | AWS EKS cluster oidc provider arn | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Indicates where EKS cluster located (default value us-east-1) | `string` | `"us-east-1"` | no |
| <a name="input_route53_zone_name"></a> [route53\_zone\_name](#input\_route53\_zone\_name) | Name of route 53 for external dns | `string` | n/a | yes |
| <a name="input_velero"></a> [velero](#input\_velero) | Enable velero add-ons | `bool` | `true` | no |
| <a name="input_velero_chart_version"></a> [velero\_chart\_version](#input\_velero\_chart\_version) | Valero chart version to use for the valero addons(i.e.: `4.1.3`) | `string` | `"4.1.3"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC where the cluster was provisioned | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_chart_version"></a> [alb\_chart\_version](#output\_alb\_chart\_version) | chart version used for alb helmchart |
| <a name="output_alb_iam_policy"></a> [alb\_iam\_policy](#output\_alb\_iam\_policy) | IAM Policy name used in alb irsa |
| <a name="output_alb_namespace"></a> [alb\_namespace](#output\_alb\_namespace) | Namespace where alb is installed |
| <a name="output_alb_service_account"></a> [alb\_service\_account](#output\_alb\_service\_account) | name of alb service-account |
| <a name="output_aws_ebs_csi_driver_chart_version"></a> [aws\_ebs\_csi\_driver\_chart\_version](#output\_aws\_ebs\_csi\_driver\_chart\_version) | chart version used for aws-ebs-csi-driver helmchart |
| <a name="output_aws_ebs_csi_driver_iam_policy"></a> [aws\_ebs\_csi\_driver\_iam\_policy](#output\_aws\_ebs\_csi\_driver\_iam\_policy) | IAM Policy name used in aws-ebs-csi-driver irsa |
| <a name="output_aws_ebs_csi_driver_namespace"></a> [aws\_ebs\_csi\_driver\_namespace](#output\_aws\_ebs\_csi\_driver\_namespace) | Namespace where aws-ebs-csi-driver is installed |
| <a name="output_aws_ebs_csi_driver_service_account"></a> [aws\_ebs\_csi\_driver\_service\_account](#output\_aws\_ebs\_csi\_driver\_service\_account) | name of aws-ebs-csi-driver service-account |
| <a name="output_cluster_autoscaler_chart_version"></a> [cluster\_autoscaler\_chart\_version](#output\_cluster\_autoscaler\_chart\_version) | chart version used for cluster-autoscaler helmchart |
| <a name="output_cluster_autoscaler_iam_policy"></a> [cluster\_autoscaler\_iam\_policy](#output\_cluster\_autoscaler\_iam\_policy) | IAM Policy name used in cluster-autoscaler irsa |
| <a name="output_cluster_autoscaler_namespace"></a> [cluster\_autoscaler\_namespace](#output\_cluster\_autoscaler\_namespace) | Namespace where cluster-autoscaler is installed |
| <a name="output_cluster_autoscaler_service_account"></a> [cluster\_autoscaler\_service\_account](#output\_cluster\_autoscaler\_service\_account) | name of cluster-autoscaler service-account |
| <a name="output_external_dns_chart_version"></a> [external\_dns\_chart\_version](#output\_external\_dns\_chart\_version) | Chart version of the external dns Helm Chart. |
| <a name="output_external_dns_namespace"></a> [external\_dns\_namespace](#output\_external\_dns\_namespace) | The namespace where external dns is deployed. |
| <a name="output_external_secrets_chart_version"></a> [external\_secrets\_chart\_version](#output\_external\_secrets\_chart\_version) | chart version used for external-secrets helmchart |
| <a name="output_external_secrets_iam_policy"></a> [external\_secrets\_iam\_policy](#output\_external\_secrets\_iam\_policy) | Name of IAM Policy used in external-secrets irsa |
| <a name="output_external_secrets_namespace"></a> [external\_secrets\_namespace](#output\_external\_secrets\_namespace) | Namespace where external-secrets is installed |
| <a name="output_external_secrets_service_account"></a> [external\_secrets\_service\_account](#output\_external\_secrets\_service\_account) | name of external-secrets service-account |
| <a name="output_velero_chart_version"></a> [velero\_chart\_version](#output\_velero\_chart\_version) | chart version used for velero helmchart |
| <a name="output_velero_iam_policy"></a> [velero\_iam\_policy](#output\_velero\_iam\_policy) | IAM Policy name used in velero irsa |
| <a name="output_velero_namespace"></a> [velero\_namespace](#output\_velero\_namespace) | Namespace where velero is installed |
| <a name="output_velero_service_account"></a> [velero\_service\_account](#output\_velero\_service\_account) | name of velero service-account |
