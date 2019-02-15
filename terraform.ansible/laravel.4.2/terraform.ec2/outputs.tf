output "server-ip" {
  value = "${aws_eip.lab-eip.public_ip}"
}
