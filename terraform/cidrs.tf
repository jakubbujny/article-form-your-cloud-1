locals {
  vpc_first_2_octets = "172.30"
  vpc_cidr = "${local.vpc_first_2_octets}.0.0/16"
}