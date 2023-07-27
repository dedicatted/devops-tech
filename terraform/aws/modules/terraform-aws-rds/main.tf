data "aws_vpc" "vpc" {
  id = var.vpc_id
}

## Security Groups

resource "aws_security_group" "rdssql_ingress" {
  name   = "${var.name}-mssql-sg"
  vpc_id = data.aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = var.rdssql_ingress_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [data.aws_vpc.vpc.cidr_block]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
# Random string for password
resource "random_string" "random" {
  length           = 16
  special          = true
  override_special = "-_"
  min_lower        = 2
  min_special      = 2
  min_upper        = 2

}

## Amazon RDS for SQL Server

resource "aws_db_instance" "rds_sql_server" {
  engine                      = var.rdssql_engine
  engine_version              = var.rdssql_engine_version
  license_model               = "license-included"
  port                        = 1433
  identifier                  = "${var.name}-mssql"
  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = false
  apply_immediately           = false
  kms_key_id                  = var.kms_key_arn
  timezone                    = var.time_zone
  character_set_name          = var.sql_collation

  backup_window            = var.backup_windows_retention_maintenance[0]
  backup_retention_period  = var.backup_windows_retention_maintenance[1]
  maintenance_window       = var.backup_windows_retention_maintenance[2]
  delete_automated_backups = true
  skip_final_snapshot      = true
  deletion_protection      = false

  db_subnet_group_name = var.db_subnet_group_name

  instance_class = var.instance_class

  allocated_storage     = var.storage_allocation[0]
  max_allocated_storage = var.storage_allocation[1]
  storage_type          = "gp2"
  storage_encrypted     = true

  username = var.user_name
  password = random_string.random.result

  vpc_security_group_ids = [aws_security_group.rdssql_ingress.id]
}
