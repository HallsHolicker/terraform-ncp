variable "region" {
  default = "KR"
}

# public is ncloud, gov is gov-ncloud, fin is fin-ncloud
variable "site" {
  default = "public"
}

# support_vpc is only support if site is public, default value is false
variable "support_vpc" {
  default = true
}

# VPC CIDR
variable "vpc_cidr" {
  default = "192.168.0.0/16"
}

variable "vpc_zone" {
  default = "KR-2"
}

# LB Subnet Only private
variable "subnet_dev_lb" {
  default = {
    cidr        = "192.168.10.0/24"
    tag         = "t101-dev-lb"
    subnet_type = "PRIVATE"
    usage_type  = "LOADB"
  }
}

variable "subnet_dev_web" {
  default = {
    cidr        = "192.168.11.0/24"
    tag         = "t101-dev-web"
    subnet_type = "PUBLIC"
    usage_type  = "GEN"
  }
}

# LB Subnet Only private
variable "subnet_stg_lb" {
  default = {
    cidr        = "192.168.100.0/24"
    tag         = "t101-stg-lb"
    subnet_type = "PRIVATE"
    usage_type  = "LOADB"
  }
}

variable "subnet_stg_web" {
  default = {
    cidr        = "192.168.101.0/24"
    tag         = "t101-stg-web"
    subnet_type = "PRIVATE"
    usage_type  = "GEN"
  }
}
