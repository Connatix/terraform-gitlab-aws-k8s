locals {
  templates_dir = "${path.module}/templates"

  chart_version = "3.1.5"

  postgres_version_full                         = "11.6"
  postgres_version_major                        = join(".", slice(split(".", local.postgres_version_full), 0, 1))
  rds_password_kubernetes_secret_key            = "rdspwd"
  root_password_kubernetes_secret_key           = "rootpwd"
  redis_password_kubernetes_secret_key          = "redispwd"
  license_kubernetes_secret_key                 = "license"
  object_store_connection_kubernetes_secret_key = "connection"
  omniauth_provider_kubernetes_secret_key       = "provider"

  use_external_postgres     = true
  use_external_redis        = true
  use_external_object_store = true
}
