variable "vpc_id" {
  description = "default vpc us-east-1"
  default = "vpc-0f5e6ce17bb4dd77d"
}
variable "security_group_ids" {
  description = "default sg us-east-1"
  default = "sg-0654c85d379f6def2"
}
variable "name" {
  default = "develop"
}
variable "kms_key_arn" {
  description = "Should be pre-created"
}
## Security Group
variable "db_subnet_group_name" {
  type        = string
  description = "Name for the DB subnet group"
}

variable "rdssql_ingress_ports" {
  type        = list(number)
  default     = [1433]
  description = "List of ports opened from Private Subnets CIDR to RDS SQL Instance"
}

## Amazon RDS for SQL Server

variable "rdssql_engine" {
  default     = "sqlserver-web"
  description = "SQL Server Version"
}

variable "rdssql_engine_version" {

  default     = "15.00"
  description = "15.00 = SQL Server 2019 / 14.00 = SQL Server 2017 / 13.00 = SQL Server 2016 / 12.00 = SQL Server 2014"
}


variable "time_zone" {
  type        = string
  default     = "GMT Standard Time"
  description = "Database timezone"
}

variable "sql_collation" {
  type        = string
  default     = "SQL_Latin1_General_CP1_CI_AS"
  description = "SQL Server Collation"
}

variable "backup_windows_retention_maintenance" {
  type        = list(any)
  default     = ["03:00-06:00", "35", "Mon:00:00-Mon:03:00"]
  description = "Backup window time, desired retention in days, maitenance windows"
}

variable "instance_class" {
  type        = string
  default     = "db.t3.medium"
  description = "Amazon RDS DB Instance class"
  # Instance type: https://aws.amazon.com/rds/sqlserver/instance_types/
}

variable "storage_allocation" {
  type        = list(any)
  default     = ["20", "100"]
  description = "Allocated storage Gb, Max allocated storage Gb"
}

variable "user_name" {
  type        = string
  default     = "admin"
  description = "SQL Server Admin username"
}

