resource "aws_s3_bucket" "s3" {
  bucket = "${var.cluster_name}-s3-dasseti"

  tags = {
    Name      = "${var.cluster_name}-s3-dasseti"
    Terraform = "True"
  }
}

module "velero_irsa_role" {
  source                = "./irsa_roles"
  role_name             = "velero"
  attach_velero_policy  = true
  velero_s3_bucket_arns = [aws_s3_bucket.s3.arn]

  oidc_providers = {
    ex = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["velero:velero"]
    }
  }

}

resource "helm_release" "velero" {
  depends_on       = [module.velero_irsa_role]
  name             = "velero"
  description      = "A Helm chart for velero"
  chart            = "velero"
  version          = var.velero_chart_version
  repository       = "https://vmware-tanzu.github.io/helm-charts/"
  namespace        = "velero"
  create_namespace = true
  values = [<<EOF
initContainers:
  - name: velero-plugin-for-aws
    image: velero/velero-plugin-for-aws:v1.7.0
    imagePullPolicy: IfNotPresent
    volumeMounts:
      - mountPath: /target
        name: plugins
podAnnotations:
  iam.amazonaws.com/role: ${module.velero_irsa_role.iam_role_arn}
serviceAccount:
  server:
    create: true
    name: velero
    annotations:
      eks.amazonaws.com/role-arn: ${module.velero_irsa_role.iam_role_arn}
credentials:
  useSecret: false
configuration:
  backupStorageLocation:
  - name: ${var.cluster_name}-backup
    provider: aws
    bucket: ${var.cluster_name}-s3-dasseti
    default: true
  volumeSnapshotLocation:
  - name: ${var.cluster_name}-volume-snapshot
    provider: aws
 
EOF
  ]
}

resource "time_sleep" "wait_for_velero" {
  depends_on = [helm_release.velero]

  create_duration = "30s"
}
