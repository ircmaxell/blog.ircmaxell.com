
# resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
#   comment = "Cloudfront"
# }





data "aws_acm_certificate" "blog_certificate" {
  domain   = "${var.domain}"
  statuses = ["ISSUED"]
}

resource "aws_cloudfront_distribution" "blog" {
  origin {
    domain_name = "${aws_s3_bucket.blog.website_endpoint}"
    origin_id = "${var.env}.${var.domain}.origin"

    custom_origin_config {
      # origin_access_identity = "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path}"
      http_port = 80
      https_port = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
    }

  }
  enabled = true
  is_ipv6_enabled = true
  comment = "Ircmaxell's ${var.env} blog"
  default_root_object = "index.html"

  logging_config {
    include_cookies = false
    bucket = "${aws_s3_bucket.logs.bucket_domain_name}"
    prefix = "cloudfront"
  }

  aliases = ["${var.domain}"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.env}.${var.domain}.origin"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  price_class = "PriceClass_200"

  tags {
    Environment = "${var.env}"
  }

  viewer_certificate {
    acm_certificate_arn = "${data.aws_acm_certificate.blog_certificate.arn}"
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }
}