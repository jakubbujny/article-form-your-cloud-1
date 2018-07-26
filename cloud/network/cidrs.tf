locals {
  vpc_first_2_octets = "172.30"
  vpc_cidr = "${local.vpc_first_2_octets}.0.0/16"
  packer_cidr = "${local.vpc_first_2_octets}.0.0/28"
  region = "eu-central-1"
  asg_a = "${local.vpc_first_2_octets}.0.32/27"
  asg_b = "${local.vpc_first_2_octets}.0.64/27"
  asg_c = "${local.vpc_first_2_octets}.0.96/27"
  alb_a = "${local.vpc_first_2_octets}.0.128/27"
  alb_b = "${local.vpc_first_2_octets}.0.160/27"
  alb_c = "${local.vpc_first_2_octets}.0.192/27"
}