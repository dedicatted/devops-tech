output "port" {
  value = aws_redshiftserverless_workgroup.serverless.endpoint.0.port
}
output "endpoint" {
  value = aws_redshiftserverless_workgroup.serverless.endpoint.0.address
}
output "password" {
  value = random_password.master_password.result
  sensitive = true
}
