## Introduction

This a simple example setup that will get you going with *AWS EKS & ArgoCD - multi-cluster architecture with IRSA in AWS* article.

The directory contains required Terraform resources to deploy ArgoCD with muslti-cluster access configured, however, note that it includes placeholder values.

The setup also requires:
- An EKS cluster and Terraform provider configured
- Two AWS Terraform providers configured (cluster 1 and cluster 2)
- Helm provider configured

Happy deploying!

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.83 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.17.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.83 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 2.17.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | 20.34.0 |
| <a name="module_secrets_manager"></a> [secrets\_manager](#module\_secrets\_manager) | github.com/itsyndicate/terraform-aws-secrets-manager//. | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 5.19.0 |

## Resources

| Name | Type |
|------|------|
| [helm_release.argocd](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [aws_eks_cluster_auth.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_argocd_chart"></a> [argocd\_chart](#input\_argocd\_chart) | Chart name to be installed | `string` | `"argo-cd"` | no |
| <a name="input_argocd_chart_version"></a> [argocd\_chart\_version](#input\_argocd\_chart\_version) | Specify the exact chart version to install | `string` | `"7.8.9"` | no |
| <a name="input_argocd_create_namespace"></a> [argocd\_create\_namespace](#input\_argocd\_create\_namespace) | Create the namespace if it does not exist | `string` | `true` | no |
| <a name="input_argocd_namespace"></a> [argocd\_namespace](#input\_argocd\_namespace) | Namespace to install the release into | `string` | `"argocd"` | no |
| <a name="input_argocd_release_name"></a> [argocd\_release\_name](#input\_argocd\_release\_name) | Release name | `string` | `"argocd"` | no |
| <a name="input_argocd_repository"></a> [argocd\_repository](#input\_argocd\_repository) | Repository where to locate the requested chart | `string` | `"https://argoproj.github.io/argo-helm"` | no |
| <a name="input_argocd_timeout"></a> [argocd\_timeout](#input\_argocd\_timeout) | Time in seconds to wait for any individual kubernetes operation | `number` | `1200` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region to provision infrastructure in | `string` | `"eu-central-1"` | no |
| <a name="input_eks_cluster_addons"></a> [eks\_cluster\_addons](#input\_eks\_cluster\_addons) | Map of cluster addon configurations to enable for the cluster. Addon name can be the map keys or set with `name` | `any` | <pre>{<br/>  "coredns": {<br/>    "most_recent": true<br/>  },<br/>  "kube-proxy": {<br/>    "most_recent": true<br/>  },<br/>  "vpc-cni": {<br/>    "before_compute": true,<br/>    "most_recent": true<br/>  }<br/>}</pre> | no |
| <a name="input_eks_cluster_endpoint_public_access"></a> [eks\_cluster\_endpoint\_public\_access](#input\_eks\_cluster\_endpoint\_public\_access) | Indicates whether or not the Amazon EKS public API server endpoint is enabled | `bool` | `true` | no |
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | Name of the EKS cluster | `string` | `"my-eks-for-argocd-tutorial"` | no |
| <a name="input_eks_cluster_version"></a> [eks\_cluster\_version](#input\_eks\_cluster\_version) | Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.27`) | `string` | `"1.32"` | no |
| <a name="input_eks_enable_cluster_creator_admin_permissions"></a> [eks\_enable\_cluster\_creator\_admin\_permissions](#input\_eks\_enable\_cluster\_creator\_admin\_permissions) | Indicates whether or not to add the cluster creator (the identity used by Terraform) as an administrator via access entry | `bool` | `true` | no |
| <a name="input_eks_managed_node_groups"></a> [eks\_managed\_node\_groups](#input\_eks\_managed\_node\_groups) | Map of EKS managed node group definitions to create | `any` | <pre>{<br/>  "example": {<br/>    "block_device_mappings": {<br/>      "xvda": {<br/>        "device_name": "/dev/xvda",<br/>        "ebs": {<br/>          "delete_on_termination": true,<br/>          "volume_size": 20,<br/>          "volume_type": "gp3"<br/>        }<br/>      }<br/>    },<br/>    "capacity_type": "SPOT",<br/>    "desired_size": 2,<br/>    "instance_types": [<br/>      "c5a.large",<br/>      "c6a.large"<br/>    ],<br/>    "max_size": 3,<br/>    "min_size": 2<br/>  }<br/>}</pre> | no |
| <a name="input_secrets_manager_secret_keys"></a> [secrets\_manager\_secret\_keys](#input\_secrets\_manager\_secret\_keys) | List of AWS Secrets Manager secret keys | `list(string)` | <pre>[<br/>  "ARGO_CD_ALICE_USER_PASSWORD_BCRYPT",<br/>  "ARGO_CD_BOB_USER_PASSWORD_BCRYPT"<br/>]</pre> | no |
| <a name="input_secrets_manager_secret_name"></a> [secrets\_manager\_secret\_name](#input\_secrets\_manager\_secret\_name) | AWS Secrets Manager secret name | `string` | `"argocd-local-users"` | no |
| <a name="input_vpc_azs"></a> [vpc\_azs](#input\_vpc\_azs) | A list of availability zones names or ids in the region | `list(string)` | <pre>[<br/>  "eu-central-1a",<br/>  "eu-central-1b"<br/>]</pre> | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | The IPv4 CIDR block for the VPC | `string` | `"10.10.0.0/18"` | no |
| <a name="input_vpc_enable_dns_hostnames"></a> [vpc\_enable\_dns\_hostnames](#input\_vpc\_enable\_dns\_hostnames) | Should be true to enable DNS hostnames in the VPC | `bool` | `true` | no |
| <a name="input_vpc_enable_dns_support"></a> [vpc\_enable\_dns\_support](#input\_vpc\_enable\_dns\_support) | Should be true to enable DNS support in the VPC | `bool` | `true` | no |
| <a name="input_vpc_enable_nat_gateway"></a> [vpc\_enable\_nat\_gateway](#input\_vpc\_enable\_nat\_gateway) | Should be true if you want to provision NAT Gateways for each of your private networks | `bool` | `true` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | Name to be used on all the resources as identifier | `string` | `"my-vpc-for-argocd-tutorial"` | no |
| <a name="input_vpc_private_subnets"></a> [vpc\_private\_subnets](#input\_vpc\_private\_subnets) | A list of private subnets inside the VPC | `list(string)` | <pre>[<br/>  "10.10.8.0/22",<br/>  "10.10.12.0/22"<br/>]</pre> | no |
| <a name="input_vpc_public_subnets"></a> [vpc\_public\_subnets](#input\_vpc\_public\_subnets) | A list of public subnets inside the VPC | `list(string)` | <pre>[<br/>  "10.10.0.0/22",<br/>  "10.10.4.0/22"<br/>]</pre> | no |
| <a name="input_vpc_single_nat_gateway"></a> [vpc\_single\_nat\_gateway](#input\_vpc\_single\_nat\_gateway) | Should be true if you want to provision a single shared NAT Gateway across all of your private networks | `bool` | `true` | no |

## Outputs

No outputs.
