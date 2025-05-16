resource "aws_iam_role" "argocd_manager" {
  provider = aws.account1

  name = "argocd-manager"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ExplicitSelfRoleAssumption",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "ArnLike": {
          "aws:PrincipalArn": "arn:aws:iam::<AWS_ACCOUNT1_ID>:role/argocd-manager"
        }
      }
    },
    {
      "Sid": "ServiceAccountRoleAssumption",
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<AWS_ACCOUNT1_ID>:oidc-provider/oidc.eks.<AWS_REGION>.amazonaws.com/id/xxxxxxxxxxxxxxxxxxxx"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.<AWS_REGION>.amazonaws.com/id/xxxxxxxxxxxxxxxxxxxx:sub": [
            "system:serviceaccount:argocd:argocd-application-controller",
            "system:serviceaccount:argocd:argocd-applicationset-controller",
            "system:serviceaccount:argocd:argocd-server"
          ],
          "oidc.eks.<AWS_REGION>.amazonaws.com/id/xxxxxxxxxxxxxxxxxxxx:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "argocd_manager_permission" {
  provider = aws.account1

  name = "argocd-manager-permission"
  role = aws_iam_role.argocd_manager_assume_role.name

  policy = <<EOF
{
  "Version" : "2012-10-17",
  "Statement" : {
    "Effect" : "Allow",
    "Action" : "sts:AssumeRole",
    "Resource" : [
      "arn:aws:iam::<AWS_ACCOUNT2_ID>:role/argocd-deployer"
    ]
  }
}
EOF
}

resource "aws_iam_role" "argocd_deployer" {
  provider = aws.account2

  name = "argocd-deployer"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Action": "sts:AssumeRole",
    "Resource": [
      "arn:aws:iam::<AWS_ACCOUNT1_ID>:role/argocd-manager"
    ]
  }
}
EOF
}
