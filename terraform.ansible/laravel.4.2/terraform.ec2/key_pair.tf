resource "aws_key_pair" "lab-key" {
  key_name   = "lab-key"
  public_key = "${file("yourkey_id_rsa.pub")}"
}
