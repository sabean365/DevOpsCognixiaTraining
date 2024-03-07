locals {
    tags = {
        Name = var.name
        Day = 3
        Client = "BoA"
        Vendor = "Cognixia"
    }
    split_out = split("-",var.name)
    zones = length(data.aws_availability_zones.zones.names)
}