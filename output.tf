
#Public IP for output on console
output "public_ip" {
  value = aws_instance.my_ubuntu_server.public_ip #reference
}