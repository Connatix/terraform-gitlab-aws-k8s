resource "aws_iam_role" "gitlab" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AssumeEc2",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "s3-buckets-policy" {
  policy_arn = aws_iam_policy.s3-buckets-policy.arn
  role       = aws_iam_role.gitlab.name
}

// Not all acccess to s3 is available at this point through instance profiles
//// For the time being we will need an explicit IAM user to use AWS services
//// When there is support from GitLab make sure to remove the user and fall back to safer auth methods
resource "aws_iam_user" "gitlab" {
  name = var.name
}

resource "aws_iam_access_key" "gitlab" {
  user = aws_iam_user.gitlab.name
}

resource "aws_iam_user_policy_attachment" "s3-buckets-policy" {
  policy_arn = aws_iam_policy.s3-buckets-policy.arn
  user       = aws_iam_user.gitlab.name
}
