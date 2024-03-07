resource "aws_ebs_volume" "data_volume" {
     availability_zone = aws_instance.my_ubuntu_server.availability_zone
    size = 1
    tags = local.tags
}

resource "aws_volume_attachment" "ebs_att" {
    device_name  = "/dev/sdf"
    volume_id    = aws_ebs_volume.data_volume.id
    instance_id  = aws_instance.my_ubuntu_server.id
    skip_destroy = false
}
