resource "aws_vpc" "main" {
  cidr_block = "${local.vpc_cidr}"

}

output "vpc_id" {
  value = "${aws_vpc.main.id}"
}

resource "aws_internet_gateway" "internet" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "main"
  }
}


resource "aws_route_table" "internet" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.internet.id}"
  }

  tags {
    Name = "internet"
  }
}
