data "aws_subnet" "rds_subnet" {
  count = max(length(var.rds_subnet_ids), 2)
  id    = var.rds_subnet_ids[count.index]
}

resource "aws_security_group" "gitlab-rds" {
  name_prefix = "gitlab-rds"
  vpc_id      = data.aws_subnet.rds_subnet.0.vpc_id

  ingress {
    security_groups = toset([var.eks_wokers_security_group_id])
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
  }
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "2.14.0"

  name       = var.name
  identifier = var.name

  engine               = "postgres"
  engine_version       = local.postgres_version_full
  major_engine_version = local.postgres_version_major
  port                 = "5432"
  family               = "postgres11"

  instance_class    = var.db_instance_class
  allocated_storage = 20

  storage_encrypted = true
  kms_key_id        = aws_kms_key.key.arn

  iam_database_authentication_enabled = true
  username                            = var.name
  password                            = random_password.rds_password.result

  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.gitlab-rds.id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  backup_retention_period = 7

  enabled_cloudwatch_logs_exports = [
    "postgresql",
  "upgrade"]

  # DB subnet group
  subnet_ids = data.aws_subnet.rds_subnet.*.id

  # Snapshot name upon DB deletion
  final_snapshot_identifier = var.name

  # Database Deletion Protection
  deletion_protection = false
}
