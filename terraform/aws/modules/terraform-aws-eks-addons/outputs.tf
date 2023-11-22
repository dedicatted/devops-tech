#----------- CLUSTER AUTOSCALER ----------------
output "cluster_autoscaler_service_account" {
  value       = module.cluster_autoscaler[*].service_account
  description = "name of cluster-autoscaler service-account"
}
output "cluster_autoscaler_iam_policy" {
  value       = module.cluster_autoscaler[*].iam_policy
  description = "IAM Policy name used in cluster-autoscaler irsa"
}
output "cluster_autoscaler_namespace" {
  value       = module.cluster_autoscaler[*].namespace
  description = "Namespace where cluster-autoscaler is installed"
}
output "cluster_autoscaler_chart_version" {
  value       = module.cluster_autoscaler[*].chart_version
  description = "chart version used for cluster-autoscaler helmchart"
}

#----------- AWS EBS CSI DRIVER ----------------
output "aws_ebs_csi_driver_service_account" {
  value       = module.aws_ebs_csi_driver[*].service_account
  description = "name of aws-ebs-csi-driver service-account"
}
output "aws_ebs_csi_driver_iam_policy" {
  value       = module.aws_ebs_csi_driver[*].iam_policy
  description = "IAM Policy name used in aws-ebs-csi-driver irsa"
}
output "aws_ebs_csi_driver_namespace" {
  value       = module.aws_ebs_csi_driver[*].namespace
  description = "Namespace where aws-ebs-csi-driver is installed"
}
output "aws_ebs_csi_driver_chart_version" {
  value       = module.aws_ebs_csi_driver[*].chart_version
  description = "chart version used for aws-ebs-csi-driver helmchart"
}

#----------- EXTERNAL SECRETS ------------------
output "external_secrets_service_account" {
  value       = module.external_secrets[*].service_account
  description = "name of external-secrets service-account"
}
output "external_secrets_namespace" {
  value       = module.external_secrets[*].namespace
  description = "Namespace where external-secrets is installed"
}
output "external_secrets_chart_version" {
  value       = module.ingress_nginx[*].chart_version
  description = "chart version used for external-secrets helmchart"
}
output "external_secrets_iam_policy" {
  value       = module.external_secrets[*].iam_policy
  description = "Name of IAM Policy used in external-secrets irsa"
}

#----------- EXTERNAL DNS ----------------------------------
output "external_dns_namespace" {
  value       = module.external_dns[*].namespace
  description = "The namespace where external dns is deployed."
}
output "external_dns_chart_version" {
  value       = module.external_dns[*].chart_version
  description = "Chart version of the external dns Helm Chart."
}

#----------- VELERO ----------------
output "velero_service_account" {
  value       = module.velero[*].service_account
  description = "name of velero service-account"
}
output "velero_iam_policy" {
  value       = module.velero[*].iam_policy
  description = "IAM Policy name used in velero irsa"
}
output "velero_namespace" {
  value       = module.velero[*].namespace
  description = "Namespace where velero is installed"
}
output "velero_chart_version" {
  value       = module.velero[*].chart_version
  description = "chart version used for velero helmchart"
}

#----------- ALB controller ----------------
output "alb_service_account" {
  value       = module.aws_load_balancer_controller[*].service_account
  description = "name of alb service-account"
}
output "alb_iam_policy" {
  value       = module.aws_load_balancer_controller[*].iam_policy
  description = "IAM Policy name used in alb irsa"
}
output "alb_namespace" {
  value       = module.aws_load_balancer_controller[*].namespace
  description = "Namespace where alb is installed"
}
output "alb_chart_version" {
  value       = module.aws_load_balancer_controller[*].chart_version
  description = "chart version used for alb helmchart"
}