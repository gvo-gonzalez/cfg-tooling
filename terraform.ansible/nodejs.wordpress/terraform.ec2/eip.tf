resource "aws_eip" "lab-eip" {
  instance    = "${aws_instance.lab-instance.id}"
}
