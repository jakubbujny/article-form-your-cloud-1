resource "aws_subnet" "packer" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${local.packer_cidr}"
  availability_zone = "${local.region}a"

  tags {
    Name = "packer"
  }
}

resource "aws_route_table_association" "packer" {
  subnet_id = "${aws_subnet.packer.id}"
  route_table_id = "${aws_route_table.internet.id}"
}
