variable "location" {}
variable "resource_group_name" {}
variable "prefix" {}
variable "address_space" {
    type = list(string)
    default = ["10.0.0.0/16"]
}
variable "subnet_prefixes" {
    type = list(string)
    default = ["10.0.2.0/24"]
}

