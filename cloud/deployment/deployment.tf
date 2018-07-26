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


resource "aws_launch_configuration" "goapp" {
  lifecycle {
    create_before_destroy = true
  }

  name_prefix = "goapp-"
  image_id = "${data.aws_ami.goapp.id}"
  instance_type = "t2.micro"

  root_block_device = {
    volume_type = "gp2"
    volume_size = 8
    delete_on_termination = true
  }
  user_data = <<EOF1
#!/bin/bash
cd /opt/
./goapp & disown
EOF1

}

resource "aws_autoscaling_group" "goapp" {
  name = "goapp"
  max_size = 3
  min_size = 3
  desired_capacity = 3
  launch_configuration = "${aws_launch_configuration.goapp.name}"
  vpc_zone_identifier = [
    "${data.terraform_remote_state.network_state.asg_a_subnet_id}",
    "${data.terraform_remote_state.network_state.asg_b_subnet_id}",
    "${data.terraform_remote_state.network_state.asg_c_subnet_id}"]

  lifecycle {
    create_before_destroy = true
  }

  load_balancers = [
    "${aws_alb.goapp_alb.name}"]
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

resource "aws_autoscaling_attachment" "attachement" {
  alb_target_group_arn   = "${aws_alb_target_group.alb_target_group.arn}"
  autoscaling_group_name = "${aws_autoscaling_group.goapp.id}"
}

resource "aws_alb_target_group" "alb_target_group" {
  name     = "goapp_alb"
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
  protocol          = "tcp"

  default_action {
    target_group_arn = "${aws_alb_target_group.alb_target_group.arn}"
    type             = "forward"
  }
}