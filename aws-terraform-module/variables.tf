variable "philter_version" {
  type        = string
  description = "The version of Philter to deploy"
  default     = "1.3.1"
}

variable "aws_region" {
  type        = string
  description = "The AWS region in which to create the deployment"
  default     = "us-east-1"
}

variable "instance_type" {
  type        = string
  description = "The Philter EC2 instance type"
  default     = "m5.large"
}

variable "instance_keyname" {
  type        = string
  description = "SSH keyname for EC2 instances"
}

variable "subnet_id" {
  type        = string
  description = "EC2 subnet in which to launch Philter EC2 instance"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID"
}