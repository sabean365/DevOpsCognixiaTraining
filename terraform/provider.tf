# #Terraform block
# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 5.0"
#     }
#   }
# }

#Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

#Provider for SSH keypair
provider "tls" {}

#For pushing pem key into local machine
provider "local" {}
