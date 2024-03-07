#How to use terraform to use the default VPC your instance is in
data "aws_vpc" "default" {
    default = true
}

#How to leverage terraform to find availability zones
data "aws_availability_zones" "zones" {
    state = "available"    
}

output "zones" {
  value = data.aws_availability_zones.zones.names
}

output "zones_count" {
    value = local.zones
}