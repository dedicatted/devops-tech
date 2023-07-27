module "ebs_csi_irsa_role" {
  source                = "./irsa_roles"
  role_name             = "ebs-csi"
  attach_ebs_csi_policy = true
  ebs_csi_kms_cmk_ids   = [var.kms_key_arn]
  oidc_providers = {
    ex = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}

resource "helm_release" "ebs_csi_driver" {
  name       = "aws-ebs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  version    = var.ebs_chart_version
  namespace  = "kube-system"
  values = [<<EOF
storageClasses:
# Add StorageClass resources like:
- name: ebs-sc
  # annotation metadata
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
  # defaults to WaitForFirstConsumer
  volumeBindingMode: WaitForFirstConsumer
  # defaults to Delete
  reclaimPolicy: Delete
  parameters:
    type: gp3
    encrypted: "true"
    kmsKeyId: ${var.kms_key_arn}


controller:
  replicaCount: 2
  serviceAccount:
    create: true
    name: ebs-csi-controller-sa
    annotations:
      eks.amazonaws.com/role-arn: ${module.ebs_csi_irsa_role.iam_role_arn}
      meta.helm.sh/release-name: aws-ebs-csi-driver
      meta.helm.sh/release-namespace: kube-system
EOF
  ]
}
