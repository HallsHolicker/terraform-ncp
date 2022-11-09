resource "ncloud_vpc" "vpc_t101" {
  name            = "vpc-t101"
  ipv4_cidr_block = var.vpc_cidr
}

resource "ncloud_subnet" "subnet_dev_lb" {
  vpc_no         = ncloud_vpc.vpc_t101.id
  subnet         = var.subnet_dev_lb.cidr
  zone           = var.vpc_zone
  network_acl_no = ncloud_vpc.vpc_t101.default_network_acl_no
  subnet_type    = var.subnet_dev_lb.subnet_type
  name           = var.subnet_dev_lb.tag
  usage_type     = var.subnet_dev_lb.usage_type
}


resource "ncloud_subnet" "subnet_dev_web" {
  vpc_no         = ncloud_vpc.vpc_t101.id
  subnet         = var.subnet_dev_web.cidr
  zone           = var.vpc_zone
  network_acl_no = ncloud_vpc.vpc_t101.default_network_acl_no
  subnet_type    = var.subnet_dev_web.subnet_type
  name           = var.subnet_dev_web.tag
  usage_type     = var.subnet_dev_web.usage_type
}

resource "ncloud_subnet" "subnet_stg_lb" {
  vpc_no         = ncloud_vpc.vpc_t101.id
  subnet         = var.subnet_stg_lb.cidr
  zone           = var.vpc_zone
  network_acl_no = ncloud_vpc.vpc_t101.default_network_acl_no
  subnet_type    = var.subnet_stg_lb.subnet_type
  name           = var.subnet_stg_lb.tag
  usage_type     = var.subnet_stg_lb.usage_type
}


resource "ncloud_subnet" "subnet_stg_web" {
  vpc_no         = ncloud_vpc.vpc_t101.id
  subnet         = var.subnet_stg_web.cidr
  zone           = var.vpc_zone
  network_acl_no = ncloud_vpc.vpc_t101.default_network_acl_no
  subnet_type    = var.subnet_stg_web.subnet_type
  name           = var.subnet_stg_web.tag
  usage_type     = var.subnet_stg_web.usage_type
}
