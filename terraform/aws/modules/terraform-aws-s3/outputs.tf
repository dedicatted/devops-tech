output "s3_iam_access_key" {
  value = aws_iam_access_key.ses.id
}
output "s3_iam_secret_key" {
  value     = aws_iam_access_key.ses.secret
  sensitive = true
}
