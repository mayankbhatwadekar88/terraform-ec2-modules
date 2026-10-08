variable "region" {
  type = string
  validation {
    condition     = length(trimspace(var.region)) > 0
    error_message = "Please provide region name"
  }
}

variable "state_bucket_name" {
  type = string
  validation {
    condition     = length(trimspace(var.state_bucket_name)) > 3 && length(trimspace(var.state_bucket_name)) < 64
    error_message = "Bucket name should be greater than 3 characters and less than 64 "
  }

}

variable "non_current_version_retention_days" {
  type = number

  validation {
    condition     = var.non_current_version_retention_days >= 30
    error_message = "Noncurrent state versions must be retained for at least 30 days."
  }
}

variable "global_tags" {
  type = map(string)
}

