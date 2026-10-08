output "instances" {
  value = {
    for instance_key, instance in aws_instance.this :
    instance_key => {
      instance_name = instance.tags["Name"]
      private_ip    = instance.private_ip
      instance_id = instance.id
    }
  }
}

