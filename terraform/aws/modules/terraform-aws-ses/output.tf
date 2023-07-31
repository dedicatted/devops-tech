output "ses_iam_access_key" {
  value = aws_iam_access_key.ses.id
}
output "ses_iam_smtp_password" {
  value     = aws_iam_access_key.ses.ses_smtp_password_v4
  sensitive = true
}
output "ses_iam_secret_key" {
  value     = aws_iam_access_key.ses.secret
  sensitive = true
}
