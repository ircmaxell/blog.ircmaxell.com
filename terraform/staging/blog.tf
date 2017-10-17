

provider "aws" {
  region="us-east-1"
}

module "blog" {
  source = "../blog"
  domain = "beta.blog.ircmaxell.com"
  env = "staging"
  default_ttl = 60
}