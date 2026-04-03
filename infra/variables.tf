variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  type    = string
  default = "172.20.0.0/16"
}

variable "priv_subnet_1_cidr" {
  type    = string
  default = "172.20.1.0/24"
}

variable "priv_subnet_2_cidr" {
  type    = string
  default = "172.20.2.0/24"
}

variable "pub_subnet_1_cidr" {
  type    = string
  default = "172.20.3.0/24"
}

variable "pub_subnet_2_cidr" {
  type    = string
  default = "172.20.4.0/24"
}