resource "random_password" "rds_password" {
  length  = 32
  special = false
}

resource "random_password" "gitlab_root_password" {
  length  = 32
  special = false
}
