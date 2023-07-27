/*
Create SES domain identity and verify it with Route53 DNS records
*/
data "aws_route53_zone" "zone" {
  name = var.domain
}

resource "aws_ses_domain_identity" "ses_domain" {
  domain = var.domain
}

resource "aws_route53_record" "amazonses_verification_record" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "_amazonses.${var.domain}"
  type    = "TXT"
  ttl     = "600"
  records = [join("", aws_ses_domain_identity.ses_domain.*.verification_token)]
}

resource "aws_ses_domain_dkim" "ses_domain_dkim" {
  domain = join("", aws_ses_domain_identity.ses_domain.*.domain)
}

resource "aws_route53_record" "amazonses_dkim_record" {
  count   = 3
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "${aws_ses_domain_dkim.ses_domain_dkim.dkim_tokens[count.index]}._domainkey"
  type    = "CNAME"
  ttl     = "600"
  records = ["${aws_ses_domain_dkim.ses_domain_dkim.dkim_tokens[count.index]}.dkim.amazonses.com"]
}


#-----------------------------------------------------------------------------------------------------------------------
# CREATE A USER AND GROUP WITH PERMISSIONS TO SEND EMAILS FROM SES domain
#-----------------------------------------------------------------------------------------------------------------------

data "aws_iam_policy_document" "ses_policy" {
  statement {
    actions = [
      "ses:SendEmail",
      "ses:SendRawEmail",
      "ses:GetSendQuota",
      "ses:GetSendStatistics",
    ]
    resources = concat(aws_ses_domain_identity.ses_domain.*.arn, var.iam_allowed_resources)
  }
}

resource "aws_iam_group" "ses_users" {

  name = "${var.name}-ses-group"
  path = "/"
}

resource "aws_iam_group_policy" "ses_group_policy" {

  name  = "${var.name}-ses-group-policy"
  group = aws_iam_group.ses_users.name

  policy = join("", data.aws_iam_policy_document.ses_policy.*.json)
}

resource "aws_iam_user_group_membership" "ses_user" {
  user = aws_iam_user.ses.name

  groups = [
    aws_iam_group.ses_users.name
  ]
}
resource "aws_iam_user" "ses" {
  name = "${var.name}-ses"
}
resource "aws_iam_access_key" "ses" {
  user = aws_iam_user.ses.name
}

resource "aws_iam_user_policy" "sending_emails" {
  #bridgecrew:skip=BC_AWS_IAM_16:Skipping `Ensure IAM policies are attached only to groups or roles` check because this module intentionally attaches IAM policy directly to a user.
  name   = "${var.name}-ses-policy"
  policy = join("", data.aws_iam_policy_document.ses_policy.*.json)
  user   = aws_iam_user.ses.name
}
