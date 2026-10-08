region = "us-east-2"

global_tags = {
  cost_center = "learning"
  managed_by  = "terraform"
}

instances = {
  application_01 = {
    name               = "prod-application-01"
    ami_id             = "ami-0ea1cddefe0c4aed5"
    instance_type      = "t3.micro"
    subnet_id          = "subnet-0281fc4455f593d64"
    security_group_ids = ["sg-04fa4e3a4b2217e52"]

    env            = "dev"
    compliance     = "soc1"
    data_residency = "usa"
    optional_tags = {
      application = "web"
      role        = "frontend"
    }
    associate_public_ip_address = false
    key_name                    = "linux_ohio"

    root_volume = {
      type    = "gp3"
      size_gb = 20
    }
  }
}

