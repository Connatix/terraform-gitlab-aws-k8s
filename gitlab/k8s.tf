resource "kubernetes_namespace" "gitlab" {
  metadata {
    name = lower(var.name)
  }
}

resource "kubernetes_storage_class" "gitaly_storage_class" {
  metadata {
    name = "gitaly"
  }

  storage_provisioner    = "kubernetes.io/aws-ebs"
  reclaim_policy         = "Retain"
  allow_volume_expansion = true

  parameters = {
    type = "gp2"
    // TODO add support for encryption
    //    encrypted = "true"
    //    kmsKeyId  = aws_kms_key.key.arn
  }

}
