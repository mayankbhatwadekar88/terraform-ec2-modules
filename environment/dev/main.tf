module "ec2" {
  source      = "../../modules/ec2_instance"
  global_tags = var.global_tags
  instances   = var.instances
}

