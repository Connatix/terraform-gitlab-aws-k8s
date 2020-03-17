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
  vpc_security_group_ids = var.vpc_security_group_ids

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  backup_retention_period = 7

  enabled_cloudwatch_logs_exports = [
    "postgresql",
  "upgrade"]

  # DB subnet group
  subnet_ids = var.rds_subnet_ids

  # Snapshot name upon DB deletion
  final_snapshot_identifier = var.name

  # Database Deletion Protection
  deletion_protection = false
}
