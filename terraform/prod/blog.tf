

provider "aws" {
  region="us-east-1"
}

module "blog" {
  source = "../blog"
  domain = "blog.ircmaxell.com"
  env = "prod"
  default_ttl = 3600
}