terraform {
  required_providers {
    aws        = "~> 2.49"
    kubernetes = "~> 1.10"
    helm       = "~> 1.0"
    random     = "~> 2.2"
  }
}

data "aws_region" "current" {
  provider = aws
}
