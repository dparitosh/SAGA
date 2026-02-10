variable "location" {}
variable "resource_group_name" {}
variable "prefix" {}
variable "admin_username" { default = "dbadmin" }
variable "admin_password" { sensitive = true }
