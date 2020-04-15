provider "aws" {
  region = "us-east-1"
  version = "~> 2.57"
}

resource "aws_vpc" "philter_vpc" {
  cidr_block = "10.50.0.0/16"
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = "${aws_vpc.philter_vpc.id}"
  cidr_block              = "10.50.0.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = "${aws_vpc.philter_vpc.id}"
  cidr_block              = "10.50.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = "${aws_vpc.philter_vpc.id}"
  cidr_block              = "10.50.2.0/24"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = "${aws_vpc.philter_vpc.id}"
  cidr_block              = "10.50.3.0/24"
  map_public_ip_on_launch = false
}

resource "aws_internet_gateway" "philter_vpc_igw" {
  vpc_id = "${aws_vpc.philter_vpc.id}"
}

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.philter_vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.philter_vpc_igw.id}"
}

resource "aws_security_group" "elb_sg" {
  name        = "philter-elb-sg"
  description = "philter-load-balancer"
  vpc_id      = "${aws_vpc.philter_vpc.id}"
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "philter_sg" {
  name        = "philter-sg"
  description = "Used in the terraform"
  vpc_id      = "${aws_vpc.philter_vpc.id}"
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = ["${aws_security_group.elb_sg.id}"]
  }
}

resource "aws_elb" "philter_elb" {
  subnets         = ["${aws_subnet.public_subnet_1.id}", "${aws_subnet.public_subnet_2.id}"]
  security_groups = ["${aws_security_group.elb_sg.id}"]
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 10
    target              = "HTTPS:8000/api/status"
    interval            = 30
  }
  listener {
    instance_port     = 8080
    instance_protocol = "tcp"
    lb_port           = 8080
    lb_protocol       = "tcp"
  }
  tags = {
    Name = "philter-terraform-elb"
  }
}

resource "aws_launch_configuration" "philter_launch_configuration" {
  image_id                    = "ami-02447712b95a2b6ef"
  instance_type               = "m5.large"
  security_groups             = ["${aws_security_group.philter_sg.id}"]
  associate_public_ip_address = false
  root_block_device {
    volume_type           = "gp2"
    volume_size           = 20
    delete_on_termination = true
    encrypted             = true
  }
}

resource "aws_autoscaling_group" "philter_autoscaling_group" {
  launch_configuration      = "${aws_launch_configuration.philter_launch_configuration.name}"
  min_size                  = 2
  max_size                  = 10
  desired_capacity          = 2
  vpc_zone_identifier       = ["${aws_subnet.private_subnet_1.id}", "${aws_subnet.private_subnet_1.id}"]
  health_check_grace_period = 60
  health_check_type         = "ELB"
  load_balancers            = ["${aws_elb.philter_elb.name}"]
}
