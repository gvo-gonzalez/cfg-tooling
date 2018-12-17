provider "aws" {
	access_key = "${var.aws_srvc_access_key}"
	secret_key = "${var.aws_srvc_secret_key}"
	region = "${var.aws_srvc_region}"
}
