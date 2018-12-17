# Define the security group for private subnet
resource "aws_security_group" "aws_sec_group_resource_name" {
  name = "security_group_group_name"
  description = "Allow incoming HTTP/HTTPS/ICMP/Node connections & SSH access"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["x.x.0.0/16"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["x.x.0.0/16"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["x.x.0.0/16"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["x.x.x.x/32"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =  ["x.x.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Enable access to a node app here
  ingress {
    from_port = 1234
    to_port = 1234
    protocol = "tcp"
    cidr_blocks =  ["x.x.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0 
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${data.aws_vpc.aws_srvc_vpc.id}"

  tags {
    Name = "aws_sec_group_tag_name"
  }
}


# Define webserver inside the public subnet
resource "aws_instance" "ami_resource_name" {

   ami  = "${var.aws_srvc_ami}"

   availability_zone = "${var.aws_srvc_availability_zone}"
   
   instance_type = "${var.aws_srvc_ec2_type}"

   root_block_device {
        volume_size = "${var.aws_srvc_ec2_volume_size}"
   }

   key_name = "${var.aws_srvc_key_name}"
   subnet_id = "${data.aws_subnet.aws_srvc_subnet.id}"
   vpc_security_group_ids = ["${aws_security_group.aws_sec_group_resource_name}"]
   associate_public_ip_address = false
   source_dest_check = false

   # This is where we configure the instance with ansible-playbook
   #provisioner "local-exec" {
   #     command = "sleep 120; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu --private-key ~/.ssh/your_private_key.pem -i '${aws_instance.ami_resource_name.private_ip},' /path/to/your/playbook_file/playbook.yml"
   #}
   provisioner "local-exec" {
   	command = "sleep 120; ansible-playbook -i '${self.private_ip},' --private-key /path/to/your/private_key.pem /path/to/your/playbook_file/playbook.yml"	
   }
   tags {
     Name = "ec2.name_for_your_instance"
   }
   # Set the number of instances you need in this cluster
   count = 1 
}

