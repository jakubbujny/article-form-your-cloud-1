data "aws_ami" "goapp" {
  most_recent = true

  filter {
    name = "name"
    values = [
      "go-app-*"]
  }

  filter {
    name = "virtualization-type"
    values = [
      "hvm"]
  }

  owners = [
    "self"]
}

resource "aws_iam_role" "iam_role" {
  name = "iam_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "iam_instance_profile" {
  name = "web_instance_profile"
  role = "${aws_iam_role.iam_role.name}"
}

resource "aws_iam_role_policy" "iam_role_policy" {
  name = "web_iam_role_policy"
  role = "${aws_iam_role.iam_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": [":${aws_s3_bucket.photos.arn}"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject"
      ],
      "Resource": ["${aws_s3_bucket.photos.arn}/*", "${aws_s3_bucket.certbot.arn}/*"]
    }
  ]
}
EOF
}


resource "aws_launch_configuration" "goapp" {

  lifecycle {
    create_before_destroy = true
  }
  name_prefix = "goapp-"
  iam_instance_profile = "${aws_iam_instance_profile.iam_instance_profile.id}"
  image_id = "${data.aws_ami.goapp.id}"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  security_groups = ["${data.terraform_remote_state.network_state.asg_sg_id}"]

  root_block_device = {
    volume_type = "gp2"
    volume_size = 8
    delete_on_termination = true
  }
  user_data = <<EOF1
#!/bin/bash
cd /opt/
./goapp ${aws_s3_bucket.photos.bucket} ${aws_s3_bucket.certbot.bucket}
EOF1

}

resource "aws_placement_group" "placement" {
  name = "goapp"
  strategy = "spread"
}
resource "aws_autoscaling_group" "goapp" {

  name = "goapp"
  max_size = 3
  min_size = 3
  placement_group = "${aws_placement_group.placement.name}"
  desired_capacity = 3
  launch_configuration = "${aws_launch_configuration.goapp.name}"
  vpc_zone_identifier = [
    "${data.terraform_remote_state.network_state.asg_a_subnet_id}",
    "${data.terraform_remote_state.network_state.asg_b_subnet_id}",
    "${data.terraform_remote_state.network_state.asg_c_subnet_id}"]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key = "Name"
    value = "goapp"
    propagate_at_launch = true
  }
}

resource "aws_alb" "goapp_alb" {
  name = "goapp-alb"
  security_groups = [
    "${data.terraform_remote_state.network_state.alb_sg_id}"]
  internal = false
  subnets = [
    "${data.terraform_remote_state.network_state.alb_a_subnet_id}",
    "${data.terraform_remote_state.network_state.alb_b_subnet_id}",
    "${data.terraform_remote_state.network_state.alb_c_subnet_id}"]

}

output "alb_endpoint" {
  value = "${aws_alb.goapp_alb.dns_name}"
}

resource "aws_autoscaling_attachment" "attachement" {
  alb_target_group_arn   = "${aws_alb_target_group.alb_target_group.arn}"
  autoscaling_group_name = "${aws_autoscaling_group.goapp.id}"
}

resource "aws_alb_target_group" "alb_target_group" {
  name     = "goapp-alb"
  port     = "8000"
  protocol = "HTTP"
  vpc_id   = "${data.terraform_remote_state.network_state.vpc_id}"
  tags {
    name = "goapp"
  }

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 10
    path                = "/"
    port                = "8000"
  }
}

resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = "${aws_alb.goapp_alb.arn}"
  port              = "80"
  protocol          = "HTTP"


  default_action {
    target_group_arn = "${aws_alb_target_group.alb_target_group.arn}"
    type             = "forward"
  }
}
