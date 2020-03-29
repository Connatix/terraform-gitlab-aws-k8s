locals {
  s3_bucket_fragments = {
    "registry"      = "registry"
    "lfs"           = "lfs"
    "artifacts"     = "artifacts"
    "uploads"       = "uploads"
    "packages"      = "packages"
    "backups"       = "backups"
    "tmp"           = "tmp"
    "externalDiffs" = "externaldiffs"
    "pseudonymizer" = "pseudonymizer"
    "cache"         = "cache"
  }

  s3_buckets = toset(formatlist("%s-%s-%s", var.name, replace(var.domain, ".", "-"), values(local.s3_bucket_fragments)))
  # Reason for disabling S3 KMS, see: https://gitlab.com/gitlab-org/gitlab-workhorse/issues/185
  s3_bucket_kms_disable_override = [
    formatlist("%s-%s-%s", var.name, replace(var.domain, ".", "-"), local.s3_bucket_fragments["artifacts"])[0]
  ]
}

resource "aws_s3_bucket" "bucket" {
  for_each = local.s3_buckets

  bucket_prefix = each.value

  dynamic "server_side_encryption_configuration" {
    for_each = contains(local.s3_bucket_kms_disable_override, each.key) ? [] : [each.value]
    iterator = itsse

    content {
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm = "aws:kms"
        }
      }
    }
  }
}

resource "aws_iam_policy" "s3-buckets-policy" {
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetBucketLocation",
        "s3:ListBucketMultipartUploads",
        "s3:ListMultipartUploadParts",
        "s3:AbortMultipartUpload",
        "s3:ListBucket",
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:PutObjectAcl"
      ],
      "Resource": [
        ${join(",", formatlist("\"%s\"", [for b in aws_s3_bucket.bucket : b.arn]))},
        ${join(",", formatlist("\"%s/*\"", [for b in aws_s3_bucket.bucket : b.arn]))}
      ]
    }
  ]
}
EOF
}
