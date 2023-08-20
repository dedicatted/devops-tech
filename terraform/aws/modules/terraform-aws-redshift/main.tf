resource "random_password" "master_password" {
  length           = var.random_password_length
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

## Security Groups

resource "aws_security_group" "rs_ingress" {
  name   = "${var.name}-rs-sg"
  vpc_id = data.aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = var.rs_ingress_ports
    content {
      from_port       = ingress.value
      to_port         = ingress.value
      protocol        = "tcp"
      security_groups = [var.security_group_ids]
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

resource "aws_redshiftserverless_namespace" "serverless" {
  namespace_name      = "${var.name}-rs-serverless-ns"
  admin_username      = var.admin_username
  admin_user_password = random_password.master_password.result
  db_name             = "${var.name}_rs_db"
  kms_key_id          = var.kms_key_arn
}

resource "aws_redshiftserverless_workgroup" "serverless" {
  namespace_name     = aws_redshiftserverless_namespace.serverless.namespace_name
  workgroup_name     = "${var.name}-serverless-workgroup-db"
  subnet_ids         = var.subnet_ids
  security_group_ids = [aws_security_group.rs_ingress.id]
}

