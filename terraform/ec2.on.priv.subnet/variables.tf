variable "aws_srvc_access_key" {}
variable "aws_srvc_secret_key" {}
variable "aws_srvc_key_path" {}
variable "aws_srvc_key_name" {}
variable "aws_srvc_vpc_id" {}
variable "aws_srvc_subnet_id" {}
variable "aws_srvc_kpair_public_key" {}
variable "aws_srvc_ec2_type" {}
variable "aws_srvc_ec2_volume_size" {}
variable "aws_srvc_availability_zone" {}

variable "aws_srvc_region" {
  description = "Region for the VPC"
  default = "your_region_here"
}

variable "aws_srvc_ami" {
  description = "Amazon Linux AMI Ubuntu 14.04"
  default = "your_ami_here"
}

data "aws_vpc" "aws_srvc_vpc" {
  id = "${var.aws_srvc_vpc_id}"
}

data "aws_subnet" "aws_srvc_subnet" {
  id = "${var.aws_srvc_subnet_id}"
}

