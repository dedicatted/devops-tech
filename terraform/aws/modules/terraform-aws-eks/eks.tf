module "eks" {
  source                                 = "./eks"
  cluster_name                           = "${var.name}-eks"
  cluster_version                        = var.cluster_version
  cluster_endpoint_public_access         = true
  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days

  cluster_addons = {
    coredns = {
      most_recent       = true
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent       = true
      resolve_conflicts = "OVERWRITE"
    }
  }
  # AWS KMS Encryption Key
  cluster_encryption_config = [{
    provider_key_arn = var.kms_key_arn
    resources        = ["secrets"]
  }]
  #VPC and subnets
  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large"]
  }

  eks_managed_node_groups = {
    devops = {
      min_size       = 1
      max_size       = 4
      desired_size   = 1
      instance_types = ["m6i.large"]
      capacity_type  = "ON_DEMAND"
      ami_id         = var.ami_id
      # By default, EKS managed node groups will not append bootstrap script;
      # this adds it back in using the default template provided by the module
      # Note: this assumes the AMI provided is an EKS optimized AMI derivative
      enable_bootstrap_user_data = true
      bootstrap_extra_args       = "--container-runtime containerd --kubelet-extra-args '--max-pods=20'"

      pre_bootstrap_user_data = <<-EOT
        export CONTAINER_RUNTIME="containerd"
        export USE_MAX_PODS=false
      EOT
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 150
            volume_type           = "gp3"
            iops                  = 3000
            throughput            = 150
            encrypted             = true
            kms_key_id            = var.kms_key_arn
            delete_on_termination = true
          }
        }
      }
      # Because we have full control over the user data supplied, we can also run additional
      # scripts/configuration changes after the bootstrap script has been run
    }
  }

  manage_aws_auth_configmap = true

  # aws_auth_roles = [
  #   {
  #     rolearn  = var.sso_role_arn
  #     username = "diligend_admin"
  #     groups   = ["system:masters"]
  #   },
  # ]
  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/diligend_tf_admin"
      username = "diligend_tf_admin"
      groups   = ["system:masters"]
    }
  ]
  tags = {
    Environment = "devops"
    Terraform   = "true"
  }
}
