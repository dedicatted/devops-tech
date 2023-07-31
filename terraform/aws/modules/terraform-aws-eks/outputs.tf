output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}
output "cluster_name" {
  value = module.eks.cluster_name
}
output "token" {
  value = data.aws_eks_cluster_auth.cluster.token
  sensitive = true
}
output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}
output "cluster_iam_role_arn" {
  value = module.eks.cluster_iam_role_arn
}
output "cluster_security_group_id" {
  value = module.eks.cluster_primary_security_group_id
}
