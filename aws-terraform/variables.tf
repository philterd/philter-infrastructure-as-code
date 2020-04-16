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

variable "cache_auth_token" {
  type        = string
  description = "Auth token for Philter cache - should be a long random string"
  default     = "L3H9dZh3UPwTvLUS"
}

variable "instance_keyname" {
  type        = string
  description = "SSH keyname for EC2 instances"
  default     = ""
}

variable "create_bastion_instance" {
  type        = bool
  description = "Set to true to create an EC2 bastion instance"
  default     = false
}

variable "bastion_ssh_cidr" {
  type        = string
  description = "Source CIDR for SSH access to bastion instance"
  default     = "0.0.0.0/0"
}