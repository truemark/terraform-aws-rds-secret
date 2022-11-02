data "aws_rds_cluster" "cluster" {
  count = var.cluster ? 1 : 0
  cluster_identifier = var.identifier
}

data "aws_db_instance" "instance" {
  count = var.cluster ? 0 : 1
  db_instance_identifier = var.identifier
}

resource "random_password" "secret" {
  count = var.create ? 1 : 0
  length  = var.password_length
  special = false
  min_upper = 1
  min_lower = 1
  min_numeric = 1
}

resource "aws_secretsmanager_secret" "secret" {
  count = var.create ? 1 : 0
  name_prefix = "database/${var.identifier}/${var.name}-"
  description = "Application password for RDS ${var.cluster ? "Cluster" : "Instance"} ${var.identifier}"
  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "secret" {
  count = var.create ? 1 : 0
  secret_id = aws_secretsmanager_secret.secret[count.index].id
  secret_string = jsonencode({
    host = data.aws_rds_cluster.cluster.endpoint
    port = data.aws_rds_cluster.cluster.port
    dbname = var.database_name == null ? data.aws_rds_cluster.cluster.database_name : var.database_name
    username = var.username == null ? var.name : var.username
    password = random_password.secret[count.index].result
  })
}


