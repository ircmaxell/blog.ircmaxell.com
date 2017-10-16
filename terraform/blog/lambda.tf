
data "archive_file" "rss" {
  type = "zip"
  output_path = "${path.module}/assets/rss.zip"
  source_dir = "${path.module}/lambda"
}

resource "aws_iam_role" "iam_for_rss_lambda" {
  name = "rss_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com",
          "edgelambda.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "rss_lambda" {
  filename         = "${data.archive_file.rss.output_path}"
  function_name    = "rss"
  role             = "${aws_iam_role.iam_for_rss_lambda.arn}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.rss.output_base64sha256}"
  runtime          = "nodejs6.10"

  publish = true

}