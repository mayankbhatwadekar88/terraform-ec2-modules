locals {
  normalized_instances = {
    for instance_key, instance in var.instances :
    instance_key => merge(
      instance,
      {
        effective_tags = merge(
          var.global_tags,
          instance.optional_tags,
          {
            Name           = instance.name
            environment    = instance.env
            compliance     = instance.compliance
            data_residency = instance.data_residency
            launch_date    = formatdate("DD-MM-YYYY hh:mm", timeadd(timestamp(), "5h30m"))
          }
        )
      }
    )
  }
  private_instances = {
    for instance_key, instance in var.instances :
    instance_key => instance
    if !instance.associate_public_ip_address
  }
  public_instances = {
    for instance_key, instance in var.instances :
    instance_key => instance
    if instance.associate_public_ip_address
  }
}

