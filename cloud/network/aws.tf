provider "aws" {
  version = "~> 1.28"
  region     = "${local.region}"
}

terraform {
  backend "s3" {
    key = "network"
  }
}