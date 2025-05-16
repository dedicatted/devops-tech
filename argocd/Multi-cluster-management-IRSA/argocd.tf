resource "random_password" "random" {
  length           = 16
  special          = true
  override_special = "-_"
  min_lower        = 2
  min_special      = 2
  min_upper        = 2
}

resource "aws_ssm_parameter" "argocd_admin_password" {
  name  = "/argocd/admin_password"
  type  = "SecureString"
  value = random_password.random.result
}

resource "kubernetes_namespace" "argocd_namespace" {
  metadata {
    name = local.argocd_namespace
  }
}

resource "helm_release" "argocd" {
  name             = "argo-cd"
  chart            = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  version          = var.argocd_configuration.chart_version
  create_namespace = false
  namespace        = local.argocd_namespace

  values = [
    <<EOF
installCRDs: ${var.argocd_configuration.helm_deploy_crds}
server: 
  serviceAccount:
    create: true
    name: argocd-server
    annotations: {eks.amazonaws.com/role-arn: arn:aws:iam::<AWS_ACCOUNT1_ID>:role/argocd-manager}
    automountServiceAccountToken: true
configs:
  clusterCredentials:
    - name: cluster2
      server: https://xxxxxxxxxxxxxxxxxxxxxxxxxxxx.xxx.<AWS_REGION>.eks.amazonaws.com
      config: 
        awsAuthConfig:
          clusterName: "cluster2"
          roleARN: "arn:aws:iam::<AWS_ACCOUNT2_ID>:role/argocd-deployer"
        tlsClientConfig:
          insecure: false
          caData: "${base64encode(data.aws_ssm_parameter.cluster2_ca.value)}"
  secret:
    argocdServerAdminPassword: ${bcrypt(random_password.random.result)}
controller:
  serviceAccount:
    create: true
    name: argocd-application-controller
    annotations: {eks.amazonaws.com/role-arn: arn:aws:iam::<AWS_ACCOUNT1_ID>:role/argocd-manager}
    automountServiceAccountToken: true
applicationSet:
  serviceAccount:
    create: true
    name: argocd-applicationset-controller
    annotations: {eks.amazonaws.com/role-arn: arn:aws:iam::<AWS_ACCOUNT1_ID>:role/argocd-manager}
    automountServiceAccountToken: true
${var.argocd_configuration.additional_values}
EOF
  ]

  depends_on = [kubernetes_namespace.argocd_namespace]
}
