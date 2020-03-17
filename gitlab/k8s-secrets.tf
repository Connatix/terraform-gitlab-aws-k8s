resource "kubernetes_secret" "rds_password" {
  metadata {
    namespace = kubernetes_namespace.gitlab.metadata[0].name
    name      = "${var.name}-rds-password"
  }

  data = {
    "${local.rds_password_kubernetes_secret_key}" = random_password.rds_password.result
  }

}

resource "kubernetes_secret" "redis_password" {
  metadata {
    namespace = kubernetes_namespace.gitlab.metadata[0].name
    name      = "${var.name}-redis-password"
  }

  data = {
    "${local.redis_password_kubernetes_secret_key}" = random_password.redis_password.result
  }

}

resource "kubernetes_secret" "gitlab_license" {
  metadata {
    namespace = kubernetes_namespace.gitlab.metadata[0].name
    name      = "${var.name}-gitlab-license"
  }

  data = {
    "${local.license_kubernetes_secret_key}" = var.license_key
  }
}

resource "kubernetes_secret" "gitlab_root_password" {
  metadata {
    namespace = kubernetes_namespace.gitlab.metadata[0].name
    name      = "${var.name}-root-password"
  }

  data = {
    "${local.root_password_kubernetes_secret_key}" = random_password.gitlab_root_password.result
  }

}

resource "kubernetes_secret" "gitlab_object_store_connection" {
  metadata {
    namespace = kubernetes_namespace.gitlab.metadata[0].name
    name      = "${var.name}-object-store-connection"
  }

  data = {
    "${local.object_store_connection_kubernetes_secret_key}" = templatefile("${local.templates_dir}/rails.s3.tpl.yaml", {
      region     = data.aws_region.current.name
      access_key = aws_iam_access_key.gitlab.id
      secret_key = aws_iam_access_key.gitlab.secret
    })
  }

}

data "aws_s3_bucket" "registry_bucket" {
  bucket = element(regex("(\\S*${local.s3_bucket_fragments["registry"]}\\S*)", join(" ", values(aws_s3_bucket.bucket)[*].id)), 0)
}

resource "kubernetes_secret" "gitlab_docker_backups_object_store_connection" {
  metadata {
    namespace = kubernetes_namespace.gitlab.metadata[0].name
    name      = "${var.name}-backups-object-store-connection"
  }

  data = {
    "${local.object_store_connection_kubernetes_secret_key}" = templatefile("${local.templates_dir}/s3cmd.tpl.cfg", {
      access_key = aws_iam_access_key.gitlab.id
      secret_key = aws_iam_access_key.gitlab.secret
      region     = data.aws_region.current.name
    })
  }
}

resource "kubernetes_secret" "gitlab_docker_registry_object_store_connection" {
  metadata {
    namespace = kubernetes_namespace.gitlab.metadata[0].name
    name      = "${var.name}-docker-registry-object-store-connection"
  }

  data = {
    "${local.object_store_connection_kubernetes_secret_key}" = templatefile("${local.templates_dir}/registry.s3.tpl.yaml", {
      bucket     = data.aws_s3_bucket.registry_bucket.id
      access_key = aws_iam_access_key.gitlab.id
      secret_key = aws_iam_access_key.gitlab.secret
      region     = data.aws_s3_bucket.registry_bucket.region
    })
  }
}

resource "kubernetes_secret" "gitlab_omniauth_provider_saml" {
  count = var.omniauth_enabled ? 1 : 0
  metadata {
    namespace = kubernetes_namespace.gitlab.metadata[0].name
    name      = "${var.name}-omniauth-provider-saml"
  }

  data = {
    "${local.omniauth_provider_kubernetes_secret_key}" = templatefile("${local.templates_dir}/omniauth_saml.tpl.yaml", {
      name                 = var.name
      domain               = var.domain
      idp_cert_fingerprint = var.idp_fingerprint
      idp_sso_target_url   = var.idp_sso_target_url
    })
  }
}