resource "random_string" "random" {
  length           = 16
  special          = true
  override_special = "-_"
  min_lower        = 2
  min_special      = 2
  min_upper        = 2
}

resource "helm_release" "argocd" {
  name             = "argo-cd"
  chart            = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  version          = var.chart_version
  create_namespace = true
  namespace        = "argocd"
  values = [<<EOF
installCRDs: ${var.argocd_helm_deploy_crds}
#redis-ha:
#  enabled: true
#controller:
#  replicas: 1
#server:
#  replicas: 3
#repoServer:
#  replicas: 3
#applicationSet:
#  replicaCount: 3
configs:
  secret:
    argocdServerAdminPassword: ${bcrypt(random_string.random.result)}
server: 
  service:
    type: NodePort
  ingressGrpc:
    enabled: true
    isAWSALB: true
    awsALB:
      serviceType: NodePort
      backendProtocolVersion: GRPC
    tls:
      hosts: [${var.argocd_host}]
  ingress:
    enabled: true
    https: true
    annotations: {
      ingress.kubernetes.io/group.name: ${var.cluster_name},
      kubernetes.io/ingress.class: alb,
      alb.ingress.kubernetes.io/certificate-arn: ${var.acm_certificate_arn},
      alb.ingress.kubernetes.io/scheme: internet-facing,
      alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS":443}]',
      alb.ingress.kubernetes.io/target-type: ip,
      alb.ingress.kubernetes.io/group.order: 51,
      alb.ingress.kubernetes.io/healthcheck-protocol: HTTPS,
      alb.ingress.kubernetes.io/backend-protocol: HTTPS,
      alb.ingress.kubernetes.io/conditions.argo-cd-argocd-server-grpc: [{"field":"http-header","httpHeaderConfig":{"httpHeaderName": "Content-Type", "values":["application/grpc"]}}],
    } 
    hosts: [${var.argocd_host}]
EOF
  ]
}

resource "kubernetes_cluster_role_binding" "argocd-cluster-admin-role-binding" {
  depends_on = [helm_release.argocd]

  metadata {
    name = "argocd-cluster-admin-role-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "argocd-application-controller"
    namespace = "argocd"
  }
}
