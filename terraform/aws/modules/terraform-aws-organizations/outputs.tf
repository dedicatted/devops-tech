output "zone_ns" {
  value = aws_route53_record.zone-ns
}
output "access_key" {
  value = aws_iam_access_key.admin.id
}
output "secret_key" {
  value = aws_iam_access_key.admin.secret
}

output "encrypted_secret" {
  value = aws_iam_access_key.admin.encrypted_secret
}
