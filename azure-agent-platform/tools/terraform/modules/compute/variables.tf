variable "location" {}
variable "resource_group_name" {}
variable "prefix" {}
variable "subnet_id" {}
variable "vm_size" {
    default = "Standard_DS1_v2"
}
variable "admin_username" {
    default = "adminuser"
}
variable "ssh_public_key_path" {}
