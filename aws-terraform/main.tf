provider "aws" {
  region  = var.aws_region
  version = "~> 2.57"
}

variable "region_ami" {
  type = map(string)
  default = {
    us-east-1 = "ami-02447712b95a2b6ef"
    us-east-2 = "ami-0ee73da0d2a7032f6"
    us-west-1 = "ami-0ce182a9c2c4f368e"
    us-west-2 = "ami-0873538d8179fde10"
  }
}

data "aws_availability_zones" "region_azs" {}

data "template_file" "user_data" {
  template = "${file("${path.module}/userdata.sh")}"
  vars = {
    cache_host       = aws_elasticache_replication_group.philter_cache_replication_group.primary_endpoint_address
    cache_auth_token = var.cache_auth_token
  }
}

resource "aws_vpc" "philter_vpc" {
  cidr_block = "10.50.0.0/16"
  tags = {
    Name = "tf-philter-vpc"
  }
}

resource "aws_subnet" "philter_public_subnet_1" {
  vpc_id                  = aws_vpc.philter_vpc.id
  cidr_block              = "10.50.0.0/24"
  availability_zone       = data.aws_availability_zones.region_azs.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "tf-philter-public-subnet-1"
  }
}

resource "aws_subnet" "philter_public_subnet_2" {
  vpc_id                  = aws_vpc.philter_vpc.id
  cidr_block              = "10.50.1.0/24"
  availability_zone       = data.aws_availability_zones.region_azs.names[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "tf-philter-public-subnet-2"
  }
}

resource "aws_subnet" "philter_private_subnet_1" {
  vpc_id                  = aws_vpc.philter_vpc.id
  cidr_block              = "10.50.2.0/24"
  availability_zone       = data.aws_availability_zones.region_azs.names[0]
  map_public_ip_on_launch = false
  tags = {
    Name = "tf-philter-private-subnet-1"
  }
}

resource "aws_subnet" "philter_private_subnet_2" {
  vpc_id                  = aws_vpc.philter_vpc.id
  cidr_block              = "10.50.3.0/24"
  availability_zone       = data.aws_availability_zones.region_azs.names[1]
  map_public_ip_on_launch = false
  tags = {
    Name = "tf-philter-private-subnet-2"
  }
}

resource "aws_internet_gateway" "philter_vpc_igw" {
  vpc_id = aws_vpc.philter_vpc.id
}

resource "aws_eip" "philter_nat_gw_eip" {
  vpc = true
}

resource "aws_nat_gateway" "philter_nat_gw" {
  allocation_id = aws_eip.philter_nat_gw_eip.id
  subnet_id     = aws_subnet.philter_public_subnet_1.id

  tags = {
    Name = "tf-philter-vpc-nat-gateway"
  }
}

resource "aws_route_table" "philter_public_route_table" {
  vpc_id = aws_vpc.philter_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.philter_vpc_igw.id
  }
  tags = {
    Name = "tf-philter-public-subnet-route-table"
  }
}

resource "aws_route_table" "philter_private_route_table" {
  vpc_id = aws_vpc.philter_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.philter_nat_gw.id
  }
  tags = {
    Name = "tf-philter-private-subnet-route-table"
  }
}

resource "aws_route_table_association" "philter_public_subnet_1_route_table_association" {
  subnet_id      = aws_subnet.philter_public_subnet_1.id
  route_table_id = aws_route_table.philter_public_route_table.id
}

resource "aws_route_table_association" "philter_public_subnet_2_route_table_association" {
  subnet_id      = aws_subnet.philter_public_subnet_2.id
  route_table_id = aws_route_table.philter_public_route_table.id
}

resource "aws_route_table_association" "philter_private_subnet_1_route_table_association" {
  subnet_id      = aws_subnet.philter_private_subnet_1.id
  route_table_id = aws_route_table.philter_private_route_table.id
}

resource "aws_route_table_association" "philter_private_subnet_2_route_table_association" {
  subnet_id      = aws_subnet.philter_private_subnet_2.id
  route_table_id = aws_route_table.philter_private_route_table.id
}

resource "aws_security_group" "philter_elb_sg" {
  name        = "tf-philter-elb-sg"
  description = "tf-philter-load-balancer"
  vpc_id      = aws_vpc.philter_vpc.id
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "philter_sg" {
  name        = "tf-philter-sg"
  description = "Controls access to Philter"
  vpc_id      = aws_vpc.philter_vpc.id
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.philter_elb_sg.id]
  }
}

resource "aws_security_group" "philter_cache_sg" {
  name        = "tf-philter-cache-sg"
  vpc_id      = aws_vpc.philter_vpc.id
  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.philter_sg.id]
  }
}

resource "aws_elb" "philter_elb" {
  subnets         = [aws_subnet.philter_public_subnet_1.id, aws_subnet.philter_public_subnet_2.id]
  security_groups = [aws_security_group.philter_elb_sg.id]
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 10
    target              = "HTTPS:880/api/status"
    interval            = 30
  }
  listener {
    instance_port     = 8080
    instance_protocol = "tcp"
    lb_port           = 8080
    lb_protocol       = "tcp"
  }
  tags = {
    Name = "tf-philter-terraform-elb"
  }
}

resource "aws_launch_configuration" "philter_launch_configuration" {
  depends_on = [aws_elasticache_replication_group.philter_cache_replication_group]
  image_id                    = "${var.region_ami["${var.aws_region}"]}"
  instance_type               = var.instance_type
  security_groups             = [aws_security_group.philter_sg.id]
  associate_public_ip_address = false
  root_block_device {
    volume_type           = "gp2"
    volume_size           = 20
    delete_on_termination = true
    encrypted             = true
  }
  user_data = data.template_file.user_data.rendered
}

resource "aws_autoscaling_group" "philter_autoscaling_group" {
  launch_configuration      = aws_launch_configuration.philter_launch_configuration.name
  min_size                  = 2
  max_size                  = 10
  desired_capacity          = 2
  vpc_zone_identifier       = [aws_subnet.philter_private_subnet_1.id, aws_subnet.philter_private_subnet_2.id]
  health_check_grace_period = 60
  health_check_type         = "ELB"
  load_balancers            = [aws_elb.philter_elb.name]
  tag {
    key                 = "Name"
    value               = "tf-philter-${var.philter_version}"
    propagate_at_launch = true
  }
}

resource "aws_elasticache_subnet_group" "philter_cache_subnet_group" {
  name = "tf-philter-cache-subnet-group"
  subnet_ids = [
    aws_subnet.philter_private_subnet_1.id,
  aws_subnet.philter_private_subnet_2.id]
}

resource "aws_elasticache_replication_group" "philter_cache_replication_group" {
  at_rest_encryption_enabled    = true
  auth_token                    = var.cache_auth_token
  automatic_failover_enabled    = true
  auto_minor_version_upgrade    = true
  availability_zones            = [data.aws_availability_zones.region_azs.names[0], data.aws_availability_zones.region_azs.names[1]]
  engine                        = "redis"
  engine_version                = "5.0.6"
  port                          = 6379
  number_cache_clusters         = 2
  node_type                     = "cache.t3.small"
  replication_group_id          = "tf-philter-cache-replication-group"
  replication_group_description = "Philter replication group"
  security_group_ids            = [aws_security_group.philter_cache_sg.id]
  subnet_group_name             = aws_elasticache_subnet_group.philter_cache_subnet_group.name
  transit_encryption_enabled    = true
}