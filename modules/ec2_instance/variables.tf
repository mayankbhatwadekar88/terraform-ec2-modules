variable "global_tags" {
  description = "Tags applied to every EC2 instances"
  type        = map(string)
}

variable "instances" {
  type = map(object({
    name               = string
    ami_id             = string
    instance_type      = string
    subnet_id          = string
    security_group_ids = list(string)


    root_volume = object({
      type                  = string
      size_gb               = number
      encrypted             = optional(bool, true)
      delete_on_termination = optional(bool, true)
    })

    env                         = string
    compliance                  = string
    data_residency              = string
    optional_tags               = optional(map(string), {})
    associate_public_ip_address = bool
    key_name                    = string
  }))

  validation {
    condition     = length(var.instances) > 0
    error_message = "At least one EC2 instance must be specified"
  }

  validation {
    condition = alltrue([
      for instance in values(var.instances) :
      length(trimspace(instance.name)) > 0
    ])
    error_message = "Instance name cannot be empty"
  }

  validation {
    condition = alltrue([
      for instance in values(var.instances) :
      can(regex("^ami-*", instance.ami_id))
    ])
    error_message = "Provide valid ami id"
  }

  validation {
    condition = alltrue([
      for instance in values(var.instances) :
      contains(
        ["gp2", "gp3"],
        instance.root_volume.type
      )
    ])
    error_message = "Type should be gp2 or gp3"
  }

  validation {
    condition = alltrue([
      for instance in values(var.instances) :
      (
        lower(instance.env) != "prod" || instance.associate_public_ip_address == false
      )
    ])
    error_message = "Prod instance must not contain public IP"
  }
  validation {
    condition = alltrue([
      for instance in values(var.instances):
      (
        contains(
          ["dev","test","prod","qa","staging"],
	  instance.env
        )
      )
    ])
    error_message = "Invalid value for environment tag"
  }
}

