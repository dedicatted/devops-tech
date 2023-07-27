resource "aws_s3_bucket" "bucket" {
  bucket        = "${var.name}-app-s3"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "bucket" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "private"
}

resource "aws_iam_user" "user" {
  name = "${var.name}-s3-user"
  path = "/"
}

resource "aws_iam_access_key" "accesskey" {
  user = aws_iam_user.user.name
}

resource "aws_iam_user_policy" "policy" {
  name = "s3bucketpolicy"
  user = aws_iam_user.user.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect" : "Allow",
      "Action" : [ "s3:*" ],
      "Resource" : [ "${aws_s3_bucket.bucket.arn}/*" ]
    }
  ]
}
EOF

}
