resource "aws_default_security_group" "ec2" {
  vpc_id = data.aws_vpc.default.id
  egress = [ 
    {
      cidr_blocks = ["0.0.0.0/0"]
      from_port = 0
      to_port = 0
      protocol = "-1"
      description = "All Open"
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      self = false
      security_groups = []
    }
  ]
  ingress = [ 
    {
      cidr_blocks = ["0.0.0.0/0"]
      from_port = 22
      to_port = 22
      protocol = "TCP"
      description = "SSH"
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      self = false
      security_groups = []
    },
    {
      cidr_blocks = ["0.0.0.0/0"]
      from_port = 80
      to_port = 80
      protocol = "TCP"
      description = "HTTP"
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      self = false
      security_groups = []
    }
  ]
  tags = local.tags
}
resource "aws_instance" "my_ubuntu_server" {
  ami           = "ami-07d9b9ddc6cd8dd30"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_default_security_group.ec2.id] #do not use security_group_ids will destroy and recreate EC2

  tags = local.tags
  key_name = aws_key_pair.key.key_name
  root_block_device {
    volume_size = 8
    tags = local.tags
    delete_on_termination = true
  }
}
resource "null_resource" "install_apache" {
  triggers = {
    instance_id = aws_instance.my_ubuntu_server.id,
    index_html = null_resource.copy_index_html.id
  }
  depends_on = [ null_resource.copy_index_html ]
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      host = aws_instance.my_ubuntu_server.public_ip
      user = "ubuntu"
      private_key = tls_private_key.keypair.private_key_pem
    }
    inline = [
      "sudo apt update",
      "sudo apt install apache2 -y",
      "sudo hostnamectl set-hostname ${var.name}",
      "sudo cp /tmp/index.html /var/www/html/index.html"
    ]
  }
}
resource "null_resource" "curl_apache" {
  triggers = {
    instance_id = aws_instance.my_ubuntu_server.id
  }
  depends_on = [ null_resource.install_apache ]
  provisioner "local-exec" {
    command =  "curl http://${aws_instance.my_ubuntu_server.public_ip}/"  #command should be aligned with terminal you are running Terraform.   
  }
}
data "template_file" "index_html" {
  template = file("./index.html.tpl")
  vars = {
    HOSTNAME = var.name
    USER = local.split_out[3]
    DAY = local.tags.Day
    ZONE = aws_instance.my_ubuntu_server.availability_zone
  }
}
data "template_file" "count_zones" {
  count = local.zones
  template = file("./count_demo.tpl")
  vars = {
    ZONE = data.aws_availability_zones.zones.names[count.index]
  } 
}

resource "local_file" "index_html" {
    filename = "index.html"
    content = data.template_file.index_html.rendered
    directory_permission = "0600"
    file_permission = "0600"
}

resource "null_resource" "copy_index_html" {
    triggers = {
      index_html = local_file.index_html.id
      }
    depends_on = [ local_file.index_html ]
    provisioner "file" {
      connection {
        type = "ssh"
        host = aws_instance.my_ubuntu_server.public_ip
        user = "ubuntu"
        private_key = tls_private_key.keypair.private_key_pem
    }
    source      = "./index.html"
    destination = "/tmp/index.html" 
  }
}
