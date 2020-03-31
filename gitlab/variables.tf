variable "name" {
  type    = string
  default = "gitlab"
}

variable "domain" {
  type = string
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.medium"
}

variable "rds_subnet_ids" {
  type = list(string)
}

variable "rds_database_name" {
  type    = string
  default = "gitlab"
}

variable "license_key" {
  type = string
}

variable "eks_wokers_security_group_id" {
  type = string
}

variable "redis_subnet_ids" {
  type = list(string)
}

variable "redis_instance_type" {
  type    = string
  default = "cache.t3.medium"
}

variable "omniauth_enabled" {
  type    = bool
  default = true
}

variable "idp_fingerprint" {
  type    = string
  default = ""
}

variable "idp_sso_target_url" {
  type    = string
  default = ""
}

variable "certmanager_issuer_email" {
  type = string
}

variable "k8s_toleration_label" {
  type = list(object({
    key : string,
    value : string
  }))

  default = []
}

variable "ci_k8s_toleration_label" {
  type = list(object({
    key : string,
    value : string
  }))

  default = []
}

variable "smtp_config" {
  type = list(object({
    address : string,
    port : number,
    user_name : string,
    password : string,
    domain : string,
    authentication : string,
    starttls_auto : string,
    openssl_verify_mode : string
  }))
  default = []
}

variable "gitaly_storage_size_gigabytes" {
  type    = number
  default = 200
}

variable "use_internal_ingress" {
  type    = bool
  default = false
}

variable "gitlab_runner_build_resources" {
  type = object({
    cpuLimit : string, // has to be string since it can contain "m"
    memoryLimit : string,
    cpuRequests : string,
    memoryRequests : string
  })
  default = {
    "cpuLimit"       = "8"
    "memoryLimit"    = "16Gi"
    "cpuRequests"    = "2"
    "memoryRequests" = "4Gi"
  }

}