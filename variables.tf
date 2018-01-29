variable "region" {
    default = "eu-west-1"
}

variable "cidr" {
  default = "10.0.0.0/16"
}

variable "azs" {
  type = "list"
  default = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "private_subnets" {
  type = "list"
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
  type = "list"
  default = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "database_subnets" {
  type = "list"
  default = ["10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"]
}

variable "cluster_name" {}
variable "base_domain" {}
variable "ssh_public_key" {}
variable "tectonic_admin_email" {}
variable "tectonic_admin_password" {}
