data "aws_subnet" "selected" {
  for_each = local.normalized_instances
  id       = each.value.subnet_id
}

data "aws_security_group" "selected" {
  for_each = local.unique_security_group_ids
  id       = each.value
}

