variable "resource_group_name" {}
variable "location" {}
variable "prefix" {}
variable "ssh_public_key_path" {}

variable "address_space" {
  type = list(string)
}
variable "subnet_prefixes" {
  type = list(string)
}

