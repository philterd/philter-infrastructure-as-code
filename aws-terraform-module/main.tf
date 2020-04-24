provider "aws" {
  region  = var.aws_region
  version = "~> 2.57"
}

# This block looks up the latest version of Philter
# and retrieves its AMI for the execution region.
data "aws_ami" "philter_ami" {
  most_recent = true
  owners      = ["aws-marketplace"]
  filter {
    name   = "product-code"
    values = ["7jr2as9jakzphur4tldb0yfuu"]
  }
  filter {
    name   = "description"
    values = ["philter ${var.philter_version}*"]
  }
}

data "aws_availability_zones" "region_azs" {}

resource "aws_instance" "philter" {
  ami             = data.aws_ami.philter_ami.id
  instance_type   = var.instance_type
  key_name        = var.instance_keyname
  security_groups = [aws_security_group.philter_sg.id]
  subnet_id       = var.subnet_id
  tags = {
    Name = "tf-philter-${var.philter_version}"
  }
}

resource "aws_security_group" "philter_sg" {
  name        = "tf-philter-sg"
  description = "Controls access to Philter"
  vpc_id      = var.vpc_id
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}