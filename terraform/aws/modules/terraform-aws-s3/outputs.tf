output "s3_iam_access_key" {
  value = aws_iam_access_key.accesskey.id
}
output "s3_iam_secret_key" {
  value     = aws_iam_access_key.accesskey.secret
  sensitive = true
}
output "bucket_name" {
  value     = aws_s3_bucket.bucket.bucket
}