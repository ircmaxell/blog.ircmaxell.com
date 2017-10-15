terraform {
    backend "s3" {
        bucket = "terraform.blog.ircmaxell.com"
        key = "terraform/prod"
        region = "us-east-1"
    }
}