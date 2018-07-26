provider "aws" {
  version = "~> 1.28"
  region     = "eu-central-1"
}

terraform {
  backend "s3" {
    key = "state"
  }
}