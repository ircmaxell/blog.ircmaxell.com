resource "aws_iam_user" "sumologic_access" {
  name = "sumologic_blog_${var.env}"
  path = "/system/"
}

resource "aws_iam_access_key" "sumologic_access" {
  user = "${aws_iam_user.sumologic_access.name}"
}

data "aws_iam_policy_document" "sumologic_access" {
  statement = {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion"
   ]
    resources = [
      "${aws_s3_bucket.logs.arn}/*"
    ]

    effect = "Allow"

    principals = {
      type = "AWS"
      identifiers = [
        "${aws_iam_user.sumologic_access.arn}"
      ]
    }
  }
  statement = {
    actions = [
      "s3:ListBucketVersions",
      "s3:ListBucket"
   ]
    resources = [
      "${aws_s3_bucket.logs.arn}"
    ]

    effect = "Allow"

    principals = {
      type = "AWS"
      identifiers = [
        "${aws_iam_user.sumologic_access.arn}"
      ]
    }
  }
}


resource "aws_s3_bucket_policy" "sumologic_access" {
  bucket = "${aws_s3_bucket.logs.id}"
  policy = "${data.aws_iam_policy_document.sumologic_access.json}"
}
