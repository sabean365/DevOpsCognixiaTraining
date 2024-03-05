
resource "aws_instance" "my_ubuntu_server" {
  ami           = "ami-07d9b9ddc6cd8dd30"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["sg-07344347d7554de81"] #do not use security_group_ids will destroy and recreate EC2

  tags = {
    Name = var.name
  }
  key_name = var.name
}

output "public_ip" {
  value = aws_instance.my_ubuntu_server.public_ip #reference
}

provider "null" {}

resource "null_resource" "install_apache" {
  triggers = {
    instance_id = aws_instance.my_ubuntu_server.id
  }
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      host = aws_instance.my_ubuntu_server.public_ip
      user = "ubuntu"
      private_key = file("C:/Users/Sarah B/.ssh/${var.name}.pem")
    }
    inline = [
      "sudo apt update",
      "sudo apt install apache2 -y",
      "sudo hostnamectl set-hostname ${var.name}"
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