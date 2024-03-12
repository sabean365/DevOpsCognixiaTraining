resource "aws_default_security_group" "ec2" {
  vpc_id = data.aws_vpc.default.id
  egress = [
    {
      cidr_blocks      = ["0.0.0.0/0"]
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      description      = "All Open"
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      self             = false
      security_groups  = []
    }
  ]
  ingress = [
    {
      cidr_blocks      = ["0.0.0.0/0"]
      from_port        = 22
      to_port          = 22
      protocol         = "TCP"
      description      = "SSH"
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      self             = false
      security_groups  = []
    }
  ]
  tags = local.tags
}

resource "aws_instance" "my_ubuntu_server" {
  ami           = "ami-07d9b9ddc6cd8dd30"
  instance_type = "t2.micro"
  #do not use security_group_ids will destroy and recreate EC2

  tags     = local.tags
  key_name = aws_key_pair.key.key_name
  root_block_device {
    volume_size           = 8
    tags                  = local.tags
    delete_on_termination = true
  }
}

resource "null_resource" "install_ansible" {
  triggers = {
    instance_id = aws_instance.my_ubuntu_server.id
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = aws_instance.my_ubuntu_server.public_ip
      user        = "ubuntu"
      private_key = tls_private_key.keypair.private_key_pem
    }
    inline = [
      "sudo apt update",
      "sudo apt-get install -y ansible",
      "sudo hostnamectl set-hostname ${var.name}",
      "ansible --version",
      "sudo mkdir -p /etc/ansible",
      "sudo echo ${aws_instance.my_ubuntu_server.private_ip} > /tmp/hosts",
      "sudo cp /tmp/hosts /etc/ansible/hosts"
    ]
  }
}
resource "null_resource" "copy_ansible_cfg" {
  provisioner "file" {
    connection {
      type        = "ssh"
      host        = aws_instance.my_ubuntu_server.public_ip
      user        = "ubuntu"
      #private_key = file("C:/Users/kul/Downloads/${var.name}.pem")
      private_key = tls_private_key.keypair.private_key_pem
    }
    source = "ansible.cfg"
    destination = "/home/ubuntu/ansible.cfg"
  }
}
resource "null_resource" "copy_private_key" {
  provisioner "file" {
    connection {
      type        = "ssh"
      host        = aws_instance.my_ubuntu_server.public_ip
      user        = "ubuntu"
      #private_key = file("C:/Users/kul/Downloads/${var.name}.pem")
      private_key = tls_private_key.keypair.private_key_pem
    }
    source = "C:/Users/Sarah B/.ssh/${var.name}.pem"
    destination = "/home/ubuntu/.ssh/id_rsa"
  }
}