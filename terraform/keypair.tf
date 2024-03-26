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