resource "aws_instance" "this" {
  for_each                    = local.normalized_instances
  ami                         = each.value.ami_id
  instance_type               = each.value.instance_type
  subnet_id                   = each.value.subnet_id
  vpc_security_group_ids      = each.value.security_group_ids
  key_name                    = each.value.key_name
  associate_public_ip_address = each.value.associate_public_ip_address

  root_block_device {
    volume_size           = each.value.root_volume.size_gb
    volume_type           = each.value.root_volume.type
    encrypted             = true
    delete_on_termination = true

    tags = merge(each.value.effective_tags,
      {
        Name = "${each.value.name}-root"
      }
    )

  }

  tags = each.value.effective_tags

}


