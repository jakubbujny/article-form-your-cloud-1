resource "aws_subnet" "asg_a" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${local.asg_a}"
  availability_zone = "${local.region}a"

  tags {
    Name = "asg_a"
  }
}

output "asg_a_subnet_id" {
  value = "${aws_subnet.asg_a.id}"
}

resource "aws_route_table_association" "asg_a" {
  subnet_id = "${aws_subnet.asg_a.id}"
  route_table_id = "${aws_route_table.internet.id}"
}

resource "aws_subnet" "asg_b" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${local.asg_b}"
  availability_zone = "${local.region}b"

  tags {
    Name = "asg_b"
  }
}

output "asg_b_subnet_id" {
  value = "${aws_subnet.asg_b.id}"
}

resource "aws_route_table_association" "asg_b" {
  subnet_id = "${aws_subnet.asg_b.id}"
  route_table_id = "${aws_route_table.internet.id}"
}

resource "aws_subnet" "asg_c" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${local.asg_c}"
  availability_zone = "${local.region}c"

  tags {
    Name = "asg_c"
  }
}

output "asg_c_subnet_id" {
  value = "${aws_subnet.asg_c.id}"
}

resource "aws_route_table_association" "asg_c" {
  subnet_id = "${aws_subnet.asg_c.id}"
  route_table_id = "${aws_route_table.internet.id}"
}



resource "aws_subnet" "alb_a" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${local.alb_a}"
  availability_zone = "${local.region}a"

  tags {
    Name = "alb_a"
  }
}
output "alb_a_subnet_id" {
  value = "${aws_subnet.alb_a.id}"
}

resource "aws_route_table_association" "alb_a" {
  subnet_id = "${aws_subnet.alb_a.id}"
  route_table_id = "${aws_route_table.internet.id}"
}


resource "aws_subnet" "alb_b" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${local.alb_b}"
  availability_zone = "${local.region}b"

  tags {
    Name = "alb_b"
  }
}

output "alb_b_subnet_id" {
  value = "${aws_subnet.alb_b.id}"
}

resource "aws_route_table_association" "alb_b" {
  subnet_id = "${aws_subnet.alb_b.id}"
  route_table_id = "${aws_route_table.internet.id}"
}

resource "aws_subnet" "alb_c" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${local.alb_c}"
  availability_zone = "${local.region}c"

  tags {
    Name = "alb_c"
  }
}

output "alb_c_subnet_id" {
  value = "${aws_subnet.alb_c.id}"
}

resource "aws_route_table_association" "alb_c" {
  subnet_id = "${aws_subnet.alb_c.id}"
  route_table_id = "${aws_route_table.internet.id}"
}

resource "aws_security_group" "asg" {
  vpc_id = "${aws_vpc.main.id}"
  name = "asg"
  ingress {
    from_port = 8000
    to_port = 8000
    protocol = "tcp"
    cidr_blocks = ["${aws_subnet.alb_a.cidr_block}","${aws_subnet.alb_b.cidr_block}","${aws_subnet.alb_c.cidr_block}"]
  }
  egress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "asg_sg_id" {
  value = "${aws_security_group.asg.id}"
}

resource "aws_security_group" "alb" {
  vpc_id = "${aws_vpc.main.id}"
  name = "alb"
  egress {
    from_port = 8000
    to_port = 8000
    protocol = "tcp"
    cidr_blocks = ["${aws_subnet.asg_a.cidr_block}","${aws_subnet.asg_b.cidr_block}","${aws_subnet.asg_c.cidr_block}"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "alb_sg_id" {
  value = "${aws_security_group.alb.id}"
}
