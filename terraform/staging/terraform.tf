terraform {
    backend "s3" {
        bucket = "terraform.blog.ircmaxell.com"
        key = "terraform/staging"
        region = "us-east-1"
    }
}