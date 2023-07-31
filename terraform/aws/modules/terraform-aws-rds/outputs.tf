output "password" {
  value     = random_string.random.result
  sensitive = true
}
output "endpoint" {
  value = aws_db_instance.rds_sql_server.endpoint
}
