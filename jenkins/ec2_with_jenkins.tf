provider "aws" {
  region = "us-east-1"
}

#Provider for SSH keypair
provider "tls" {}

#For pushing pem key into local machine
provider "local" {}

data "aws_vpc" "default" {
  default = true
}
variable "name" {
  description = "Tag name of EC2 instance"
  default     = "thinknyx-cognixia-jump-ansible-sarah"
}
locals {
  tags = {
    Name     = "${var.name}"
    Day      = 4
    Client   = "BoA"
    Vendor   = "Cognixia"
    Software = "Ansible"
  }
}


resource "aws_default_security_group" "ec2" {
  name= var.name
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
    },
    {
      cidr_blocks      = ["0.0.0.0/0"]
      from_port        = 8080
      to_port          = 8080
      protocol         = "TCP"
      description      = "Tomcat"
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      self             = false
      security_groups  = []
    },
    {
      cidr_blocks      = ["0.0.0.0/0"]
      from_port        = 50000
      to_port          = 50000
      protocol         = "TCP"
      description      = "Jenkins-Inbound"
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      self             = false
      security_groups  = []
    },
    {
      cidr_blocks      = ["172.31.0.0/16"]
      from_port        = 0
      to_port          = 0
      protocol         = "-1" #All traffic
      description      = "all-open"
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      self             = false
      security_groups  = []
    }

  ]
  tags = local.tags
}
resource "aws_instance" "jenkins_server" {
  ami           = "ami-07d9b9ddc6cd8dd30"
  instance_type = "t2.small"
  #do not use security_group_ids will destroy and recreate EC2
  # vpc_security_group_ids = [ aws_default_security_group.ec2.ids ]
  tags     = local.tags
  key_name = aws_key_pair.key.key_name
  root_block_device {
    volume_size           = 8
    tags                  = local.tags
    delete_on_termination = true
  }
}
#create private/public ssh keypair
resource "tls_private_key" "keypair" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
resource "aws_key_pair" "key" {
  key_name   = var.name
  public_key = tls_private_key.keypair.public_key_openssh
  tags       = local.tags
}

resource "local_file" "private_key" {
  filename             = "C:/Users/Sarah B/.ssh/${var.name}.pem"
  content              = tls_private_key.keypair.private_key_pem
  directory_permission = "0600"
  file_permission      = "0600"
}
resource "null_resource" "install_ansible" {
  triggers = {
    instance_id = aws_instance.jenkins_server.id
  }
  depends_on = [null_resource.copy_ansible_cfg, null_resource.copy_private_key]
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = aws_instance.jenkins_server.public_ip
      user        = "ubuntu"
      private_key = tls_private_key.keypair.private_key_pem
    }
    inline = [
      "sudo apt update",
      "sudo apt-get install -y ansible",
      "sudo hostnamectl set-hostname ${var.name}",
      "ansible --version",
      "sudo mkdir -p /etc/ansible",
      "echo ${aws_instance.jenkins_server.private_ip} > /tmp/hosts",
      "sudo cp /tmp/hosts /etc/ansible/hosts",
      "sudo mv /tmp/ansible.cfg /etc/ansible/ansible.cfg",
      "chmod 600 ~/.ssh/id_rsa"
    ]
  }
}
resource "null_resource" "copy_ansible_cfg" {
  provisioner "file" {
    connection {
      type = "ssh"
      host = aws_instance.jenkins_server.public_ip
      user = "ubuntu"
      #private_key = file("C:/Users/kul/Downloads/${var.name}.pem")
      private_key = tls_private_key.keypair.private_key_pem
    }
    source      = "ansible.cfg"
    destination = "/tmp/ansible.cfg"
  }
}
resource "null_resource" "copy_private_key" {
  provisioner "file" {
    connection {
      type        = "ssh"
      host        = aws_instance.jenkins_server.public_ip
      user        = "ubuntu"
      private_key = tls_private_key.keypair.private_key_pem
    }
    source      = "C:/Users/Sarah B/.ssh/${var.name}.pem"
    destination = "/home/ubuntu/.ssh/id_rsa"
  }
}
resource "null_resource" "copy_jenkins_playbook" {
  triggers = {
    timestamp = timestamp()
  }
  provisioner "file" {
    connection {
      type        = "ssh"
      host        = aws_instance.jenkins_server.public_ip
      user        = "ubuntu"
      private_key = tls_private_key.keypair.private_key_pem
    }
    source      = "setup_jenkins.yml"
    destination = ""
  }
}
resource "null_resource" "copy_manifest" {
  triggers = {
    timestamp = timestamp()
  }
  provisioner "file" {
    connection {
      type        = "ssh"
      host        = aws_instance.jenkins_server.public_ip
      user        = "ubuntu"
      private_key = tls_private_key.keypair.private_key_pem
    }
    source = "./manifests/"
    destination = "/tmp/manifests/"
  }
}
resource "null_resource" "copy_jenkins_playbook" {
  triggers = {
    timestamp = timestamp()
  }
  provisioner "file" {
    connection {
      type        = "ssh"
      host        = aws_instance.jenkins_server.public_ip
      user        = "ubuntu"
      private_key = tls_private_key.keypair.private_key_pem
    }
    source = "setup_jenkins.yml"
    destination = "setup_jenkins.yml"
  }
}
resource "null_resource" "setup_jenkins" {
  depends_on = [ 
    null_resource.install_ansible,
    null_resource.copy_jenkins_playbook
  ]
  triggers = {
    copy_jenkins_playbook = null_resource.copy_jenkins_playbook.id
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = aws_instance.jenkins_server.public_ip
      user        = "ubuntu"
      private_key = tls_private_key.keypair.private_key_pem
    }
    inline = [
      "ansible-playbook setup_jenkins.yml"
    ]
  }
}

output "Jenkins_Server_Public_IP" {
  value = aws_instance.jenkins_server.public_ip
}

output "Jenkins_Server_URL" {
  value = "http://${aws_instance.jenkins_server.public_ip}:8080"
}