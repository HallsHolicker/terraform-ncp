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

variable "vpc_zone" {
  default = "KR-2"
}

variable "key_name" {
  default = "hallsholicker-ncp"
}

# Centos 7.8
variable "server_image_product_code" {
  default = "SW.VSVR.OS.LNX64.CNTOS.0708.B050"
}

# G2 vCPU 2ea, 8GB RAM, SSD 50GB
variable "server_product_code" {
  default = "SVR.VSVR.STAND.C002.M008.NET.SSD.B050.G002"
}

variable "web_server_name" {
  default = "vm-t101-stg-web"
}

variable "web_server_count" {
  default = 2
}
