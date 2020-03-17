resource "random_password" "redis_password" {
  length  = 16
  special = false
}

data "aws_subnet" "redis_subnet" {
  count = max(length(var.redis_subnet_ids), 2)
  id    = var.redis_subnet_ids[count.index]
}

module "redis" {
  source = "git::https://github.com/cloudposse/terraform-aws-elasticache-redis.git?ref=0.16.0"

  name                       = var.name
  vpc_id                     = data.aws_subnet.redis_subnet.0.vpc_id
  availability_zones         = toset(data.aws_subnet.redis_subnet.*.availability_zone)
  subnets                    = toset(var.redis_subnet_ids)
  allowed_security_groups    = var.vpc_security_group_ids
  instance_type              = var.redis_instance_type
  family                     = "redis5.0"
  engine_version             = "5.0.6"
  at_rest_encryption_enabled = true

  transit_encryption_enabled = true
  auth_token                 = random_password.redis_password.result

  // TODO Consider changin this to a true redis cluster
  // TODO Currently the installation is not working with external redis
  cluster_mode_enabled       = false
  automatic_failover_enabled = false
  cluster_size               = 1

  apply_immediately = true
}
