# for minikube k8s cluster on local server  

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}


# In case you use Terraform to create EKS cluster
# You can dynamically obtain a token to authenticate with a cluster

# provider "helm" {
#   kubernetes {
#     host                   = aws_eks_cluster.demo.endpoint
#     cluster_ca_certificate = base64decode(aws_eks_cluster.demo.certificate_authority[0].data)
#     exec {
#       api_version = "client.authentication.k8s.io/v1beta1"
#       args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.demo.id]
#       command     = "aws"
#     }
#   }
# }