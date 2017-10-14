
resource "aws_s3_bucket" "blog" {
  bucket = "in.bucket.${var.domain}"
  acl = "public-read"

  website {
    index_document = "index.html"
  }

  tags {
    ENV = "${var.env}"
  }
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.blog.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["${aws_s3_bucket.blog.arn}"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "s3_policy" {
  bucket = "${aws_s3_bucket.blog.id}"
  policy = "${data.aws_iam_policy_document.s3_policy.json}"
}

resource "aws_s3_bucket" "logs" {
  bucket = "in.logs.${var.domain}"
  acl = "private"

  tags {
    ENV = "${var.env}"
  }
}