variable "aws_region" {
  type = string
}

variable "aws_role_arn" {
  type = string
}

variable "name" {
  type = string
}

provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn = var.aws_role_arn
  }
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  version = "1.10.0"

  load_config_file       = false
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

provider "random" {
  version = "2.2.1"
}

provider "helm" {
  version = "1.0.0"

  kubernetes {
    load_config_file       = false
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.name
  cidr = "172.69.0.0/16"

  azs = ["us-east-2a", "us-east-2b", "us-east-2c"]

  private_subnets = ["172.69.0.0/24", "172.69.1.0/24", "172.69.2.0/24"]
  public_subnets  = ["172.69.3.0/24", "172.69.4.0/24", "172.69.5.0/24"]

  enable_nat_gateway   = true
  enable_dns_hostnames = true
  enable_vpn_gateway   = false

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.name}" = "shared"
    "kubernetes.io/role/internal-elb"   = "1"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb"            = "1"
    "kubernetes.io/cluster/${var.name}" = "shared"
  }

  tags = {
    "kubernetes.io/cluster/${var.name}" = "shared"
  }
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name    = var.name
  cluster_version = "1.14"
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  worker_groups = [
    {
      instance_type = "m5.2xlarge"
      asg_max_size  = 4
    }
  ]
}

module "gitlab" {
  source = "../gitlab"

  license_key              = file("license.key")
  domain                   = "yourdomain.com"
  rds_subnet_ids           = module.vpc.private_subnets
  redis_subnet_ids         = module.vpc.private_subnets
  certmanager_issuer_email = "admin@yourdomain.com"

  omniauth_enabled             = true
  idp_fingerprint              = "AA:BB:CC:DD:EE:FF:FF:EE:DD:CC:BB:AA"
  idp_sso_target_url           = "https://accounts.google.com/o/saml2/idp?idpid=X"
  eks_wokers_security_group_id = module.vpc.default_security_group_id
}
