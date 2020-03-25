locals {
  # According to https://gitlab.com/gitlab-org/charts/gitlab/-/blob/master/values.yaml
  helm_gitlab_sets = {
    "edition"                           = "ee"
    "global.hosts.domain"               = var.domain
    "global.gitlab.license.secret"      = kubernetes_secret.gitlab_license.metadata[0].name
    "global.gitlab.license.key"         = local.license_kubernetes_secret_key
    "global.initialRootPassword.secret" = kubernetes_secret.gitlab_root_password.metadata[0].name
    "global.initialRootPassword.key"    = local.root_password_kubernetes_secret_key

    # External Postgres, Redis and Object Storage Config. All should be false.
    "postgresql.install"   = local.use_external_postgres ? "false" : "true"
    "redis.install"        = local.use_external_redis ? "false" : "true"
    "global.minio.enabled" = local.use_external_object_store ? "false" : "true"

    "global.registry.bucket"  = element(regex("(\\S*${local.s3_bucket_fragments["registry"]}\\S*)", join(" ", values(aws_s3_bucket.bucket)[*].id)), 0)
    "registry.storage.secret" = kubernetes_secret.gitlab_docker_registry_object_store_connection.metadata[0].name
    "registry.storage.key"    = local.object_store_connection_kubernetes_secret_key

    "global.appConfig.backups.bucket"                        = element(regex("(\\S*${local.s3_bucket_fragments["backups"]}\\S*)", join(" ", values(aws_s3_bucket.bucket)[*].id)), 0)
    "global.appConfig.backups.tmpBucket"                     = element(regex("(\\S*${local.s3_bucket_fragments["tmp"]}\\S*)", join(" ", values(aws_s3_bucket.bucket)[*].id)), 0)
    "gitlab.task-runner.backups.objectStorage.config.secret" = kubernetes_secret.gitlab_docker_backups_object_store_connection.metadata[0].name
    "gitlab.task-runner.backups.objectStorage.config.key"    = local.object_store_connection_kubernetes_secret_key

    # CertManager
    "global.ingress.configureCertmanager" = "true"
    "certmanager-issuer.email" : var.certmanager_issuer_email

    # Gitaly
    # According to https://docs.gitlab.com/charts/charts/globals.html#internal
    "gitlab.gitaly.persistence.storageClass" = kubernetes_storage_class.gitaly_storage_class.metadata[0].name
    "gitlab.gitaly.persistence.size"         = "${var.gitaly_storage_size_gigabytes}Gi"

    # Misc
    "global.appConfig.defaultCanCreateGroup"   = "false"
    "global.appConfig.usernameChangingEnabled" = "false"

    # Other
    "prometheus.server.enabled" = "false"
  }

  helm_toleration_sets = {
    "gitlab.gitaly.tolerations[0].key"                                                  = var.k8s_toleration_label.0.key
    "gitlab.gitaly.tolerations[0].value"                                                = var.k8s_toleration_label.0.value
    "gitlab.gitaly.tolerations[0].effect"                                               = "NoSchedule"
    "gitlab.gitaly.nodeSelector.${replace(var.k8s_toleration_label.0.key, ".", "\\.")}" = var.k8s_toleration_label[0].value

    "gitlab.gitlab-exporter.tolerations[0].key"                                                  = var.k8s_toleration_label.0.key
    "gitlab.gitlab-exporter.tolerations[0].value"                                                = var.k8s_toleration_label.0.value
    "gitlab.gitlab-exporter.tolerations[0].effect"                                               = "NoSchedule"
    "gitlab.gitlab-exporter.nodeSelector.${replace(var.k8s_toleration_label.0.key, ".", "\\.")}" = var.k8s_toleration_label[0].value

    "gitlab.gitlab-runner.tolerations[0].key"                                                  = var.k8s_toleration_label.0.key
    "gitlab.gitlab-runner.tolerations[0].value"                                                = var.k8s_toleration_label.0.value
    "gitlab.gitlab-runner.tolerations[0].effect"                                               = "NoSchedule"
    "gitlab.gitlab-runner.nodeSelector.${replace(var.k8s_toleration_label.0.key, ".", "\\.")}" = var.k8s_toleration_label[0].value

    "gitlab.gitlab-shell.tolerations[0].key"                                                  = var.k8s_toleration_label.0.key
    "gitlab.gitlab-shell.tolerations[0].value"                                                = var.k8s_toleration_label.0.value
    "gitlab.gitlab-shell.tolerations[0].effect"                                               = "NoSchedule"
    "gitlab.gitlab-shell.nodeSelector.${replace(var.k8s_toleration_label.0.key, ".", "\\.")}" = var.k8s_toleration_label[0].value

    "gitlab.migrations.tolerations[0].key"                                                  = var.k8s_toleration_label.0.key
    "gitlab.migrations.tolerations[0].value"                                                = var.k8s_toleration_label.0.value
    "gitlab.migrations.tolerations[0].effect"                                               = "NoSchedule"
    "gitlab.migrations.nodeSelector.${replace(var.k8s_toleration_label.0.key, ".", "\\.")}" = var.k8s_toleration_label[0].value

    "gitlab.sidekiq.tolerations[0].key"                                                  = var.k8s_toleration_label.0.key
    "gitlab.sidekiq.tolerations[0].value"                                                = var.k8s_toleration_label.0.value
    "gitlab.sidekiq.tolerations[0].effect"                                               = "NoSchedule"
    "gitlab.sidekiq.nodeSelector.${replace(var.k8s_toleration_label.0.key, ".", "\\.")}" = var.k8s_toleration_label[0].value

    "gitlab.unicorn.tolerations[0].key"                                                  = var.k8s_toleration_label.0.key
    "gitlab.unicorn.tolerations[0].value"                                                = var.k8s_toleration_label.0.value
    "gitlab.unicorn.tolerations[0].effect"                                               = "NoSchedule"
    "gitlab.unicorn.nodeSelector.${replace(var.k8s_toleration_label.0.key, ".", "\\.")}" = var.k8s_toleration_label[0].value

    "shared-secrets.tolerations[0].key"                                                  = var.k8s_toleration_label.0.key
    "shared-secrets.tolerations[0].value"                                                = var.k8s_toleration_label.0.value
    "shared-secrets.tolerations[0].effect"                                               = "NoSchedule"
    "shared-secrets.nodeSelector.${replace(var.k8s_toleration_label.0.key, ".", "\\.")}" = var.k8s_toleration_label[0].value

    "nginx-ingress.controller.tolerations[0].key"                                                  = var.k8s_toleration_label.0.key
    "nginx-ingress.controller.tolerations[0].value"                                                = var.k8s_toleration_label.0.value
    "nginx-ingress.controller.tolerations[0].effect"                                               = "NoSchedule"
    "nginx-ingress.controller.nodeSelector.${replace(var.k8s_toleration_label.0.key, ".", "\\.")}" = var.k8s_toleration_label[0].value

    "registry.tolerations[0].key"                                                  = var.k8s_toleration_label.0.key
    "registry.tolerations[0].value"                                                = var.k8s_toleration_label.0.value
    "registry.tolerations[0].effect"                                               = "NoSchedule"
    "registry.nodeSelector.${replace(var.k8s_toleration_label.0.key, ".", "\\.")}" = var.k8s_toleration_label[0].value
  }

  # External Database
  # According to https://docs.gitlab.com/charts/advanced/external-db/
  helm_psql_sets = {
    "host"            = module.db.this_db_instance_address
    "port"            = module.db.this_db_instance_port
    "database"        = module.db.this_db_instance_name
    "password.secret" = kubernetes_secret.rds_password.metadata[0].name
    "password.key"    = local.rds_password_kubernetes_secret_key
  }

  # External Redis
  # According to https://docs.gitlab.com/charts/advanced/external-redis/
  helm_redis_sets = {
    "host"            = module.redis.endpoint
    "password.secret" = kubernetes_secret.redis_password.metadata[0].name
    "password.key"    = local.redis_password_kubernetes_secret_key
  }

  # External Object Storage
  # According to https://docs.gitlab.com/charts/advanced/external-object-storage/
  helm_s3_buckets_sets = {
    "lfs.bucket"            = element(regex("(\\S*${local.s3_bucket_fragments["lfs"]}\\S*)", join(" ", values(aws_s3_bucket.bucket)[*].id)), 0)
    "lfs.connection.secret" = kubernetes_secret.gitlab_object_store_connection.metadata[0].name
    "lfs.connection.key"    = local.object_store_connection_kubernetes_secret_key

    "artifacts.bucket"            = element(regex("(\\S*${local.s3_bucket_fragments["artifacts"]}\\S*)", join(" ", values(aws_s3_bucket.bucket)[*].id)), 0)
    "artifacts.connection.secret" = kubernetes_secret.gitlab_object_store_connection.metadata[0].name
    "artifacts.connection.key"    = local.object_store_connection_kubernetes_secret_key

    "uploads.bucket"            = element(regex("(\\S*${local.s3_bucket_fragments["uploads"]}\\S*)", join(" ", values(aws_s3_bucket.bucket)[*].id)), 0)
    "uploads.connection.secret" = kubernetes_secret.gitlab_object_store_connection.metadata[0].name
    "uploads.connection.key"    = local.object_store_connection_kubernetes_secret_key

    "packages.bucket"            = element(regex("(\\S*${local.s3_bucket_fragments["packages"]}\\S*)", join(" ", values(aws_s3_bucket.bucket)[*].id)), 0)
    "packages.connection.secret" = kubernetes_secret.gitlab_object_store_connection.metadata[0].name
    "packages.connection.key"    = local.object_store_connection_kubernetes_secret_key

    "backups.bucket"            = element(regex("(\\S*${local.s3_bucket_fragments["backups"]}\\S*)", join(" ", values(aws_s3_bucket.bucket)[*].id)), 0)
    "backups.connection.secret" = kubernetes_secret.gitlab_object_store_connection.metadata[0].name
    "backups.connection.key"    = local.object_store_connection_kubernetes_secret_key

    "externalDiffs.enabled"           = "true"
    "externalDiffs.bucket"            = element(regex("(\\S*${local.s3_bucket_fragments["externalDiffs"]}\\S*)", join(" ", values(aws_s3_bucket.bucket)[*].id)), 0)
    "externalDiffs.connection.secret" = kubernetes_secret.gitlab_object_store_connection.metadata[0].name
    "externalDiffs.connection.key"    = local.object_store_connection_kubernetes_secret_key

    "pseudonymizer.bucket"            = element(regex("(\\S*${local.s3_bucket_fragments["pseudonymizer"]}\\S*)", join(" ", values(aws_s3_bucket.bucket)[*].id)), 0)
    "pseudonymizer.connection.secret" = kubernetes_secret.gitlab_object_store_connection.metadata[0].name
    "pseudonymizer.connection.key"    = local.object_store_connection_kubernetes_secret_key

  }

  # OmniAuth Configuration
  # According to https://docs.gitlab.com/charts/charts/globals.html#omniauth
  # Also see:
  # * https://medium.com/mop-developers/how-to-set-up-gitlab-single-sign-on-with-google-g-suite-f5e88ae8ba7
  # * https://docs.gitlab.com/ee/integration/saml.html
  omniauth_provider_id = "saml"
  helm_omniauth_sets = {
    "enabled" = var.omniauth_enabled
    //    "autoSignInWithProvider"  = local.omniauth_provider_id
    "syncProfileFromProvider[0]" = local.omniauth_provider_id
    "syncProfileAttributes[0]"   = "email"
    "allowSingleSignOn[0]"       = local.omniauth_provider_id
    "blockAutoCreatedUsers"      = "false"
    "autoLinkSamlUser"           = "true"
    "allowBypassTwoFactor[0]"    = local.omniauth_provider_id
    "providers[0].secret"        = kubernetes_secret.gitlab_omniauth_provider_saml[0].metadata[0].name
    "providers[0].key"           = local.omniauth_provider_kubernetes_secret_key
  }

  # Nginx
  helm_nginx_internal_sets = {
    "nginx-ingress.controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-internal" = "true"
  }

  //  helm_smtp_sets = {
  //    enabled: false
  //    address: smtp.mailgun.org
  //    port: 2525
  //    user_name: ""
  //    ## doc/installation/secrets.md#smtp-password
  //    password:
  //    secret: ""
  //    key: password
  //    # domain:
  //    authentication: "plain"
  //    starttls_auto: false
  //    openssl_verify_mode: "peer"
  //  }

  helm_cron_backup_sets = {
    # Backups
    "enabled"   = "true"
    "schedule"  = "0 12 * * *"
    "extraArgs" = local.use_external_postgres ? "--skip db" : ""
  }

  helm_gitlab_runner_toleration_sets = {
    "tolerations[0].key"                                                     = var.ci_k8s_toleration_label.0.key
    "tolerations[0].value"                                                   = var.ci_k8s_toleration_label.0.value
    "tolerations[0].effect"                                                  = "NoSchedule"
    "nodeSelector.${replace(var.ci_k8s_toleration_label.0.key, ".", "\\.")}" = var.ci_k8s_toleration_label[0].value
  }
}

data "helm_repository" "gitlab" {
  name = "gitlab"
  url  = "https://charts.gitlab.io/"
}

# See: https://docs.gitlab.com/charts/installation/command-line-options.html
resource "helm_release" "gitlab" {
  chart      = "gitlab"
  name       = var.name
  namespace  = kubernetes_namespace.gitlab.metadata[0].name
  repository = data.helm_repository.gitlab.metadata[0].name
  version    = local.chart_version

  dynamic "set" {
    for_each = local.helm_gitlab_sets
    content {
      name  = set.key
      value = set.value
    }
  }

  dynamic "set" {
    for_each = local.use_external_postgres ? local.helm_psql_sets : {}
    content {
      name  = "global.psql.${set.key}"
      value = set.value
    }
  }

  dynamic "set" {
    for_each = local.use_external_redis ? local.helm_redis_sets : {}
    content {
      name  = "global.redis.${set.key}"
      value = set.value
    }
  }

  dynamic "set" {
    for_each = local.use_external_object_store ? local.helm_s3_buckets_sets : {}
    content {
      name  = "global.appConfig.${set.key}"
      value = set.value
    }
  }

  dynamic "set" {
    for_each = var.omniauth_enabled ? local.helm_omniauth_sets : {}
    content {
      name  = "global.appConfig.omniauth.${set.key}"
      value = set.value
    }
  }

  dynamic "set" {
    for_each = local.helm_cron_backup_sets
    content {
      name  = "gitlab.task-runner.backups.cron.${set.key}"
      value = set.value
    }
  }

  dynamic "set" {
    for_each = length(var.k8s_toleration_label) != 0 ? local.helm_toleration_sets : {}
    content {
      name  = set.key
      value = set.value
    }
  }

  dynamic "set" {
    for_each = var.use_internal_ingress ? local.helm_nginx_internal_sets : {}
    content {
      name  = set.key
      value = set.value
    }
  }

  dynamic "set" {
    for_each = length(var.ci_k8s_toleration_label) != 0 ? local.helm_gitlab_runner_toleration_sets : {}
    content {
      name  = "gitlab-runner.${set.key}"
      value = set.value
    }
  }

  timeout = 600

}

