resource "aws_instance" "lab-instance" {
  ami             = "${data.aws_ami.ubuntu.id}"
  instance_type   = "t2.micro"
  key_name        = "${aws_key_pair.lab-key.key_name}"
  
  security_groups = [
    "${aws_security_group.lab_basic_secgroup.name}"
  ]
  
#   provisioner "local-exec" {
#        command = "sleep 120; ansible-playbook -i '${self.public_ip},' -u ubuntu --private-key /path/to/key/aws_privkey_id_rsa /path/to/ansible/playbook.yml"
#   }
#  provisioner "local-exec" {
#  	command = "ansible all -i '${self.public_ip},' -u ubuntu -m ping --private-key ~/.ssh/aws_privkey_id_rsa"
#  }

  tags {
    Name = "ec2-lab"
  }
}
