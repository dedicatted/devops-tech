resource "aws_security_group" "redis_ingress" {
  name   = "${var.name}-redis-sg"
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.redis_ingress_ports
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

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.name}-redis"
  engine               = var.engine
  node_type            = var.node_type
  num_cache_nodes      = var.num_cache_nodes
  parameter_group_name = var.parameter_group_name
  engine_version       = var.engine_version
  port                 = var.port
  security_group_ids   = [aws_security_group.redis_ingress.id]
  subnet_group_name    = var.subnet_group_name
  az_mode              = var.num_cache_nodes > 1 ? "cross-az" : "single-az"

}
