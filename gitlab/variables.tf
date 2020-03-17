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

variable "vpc_security_group_ids" {
  type = list(string)
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