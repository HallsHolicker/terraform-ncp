# Global 설정 구성

## Create Folder
```
mkdir global && cd global
```

## Create main.tf

NCP Provider 설정을 위한 main.tf 생성

```
cat << EOF > main.tf
terraform {
  required_version = " >= 0.13"
  required_providers {
    ncloud = {
      source = "navercloudplatform/ncloud"
    }
  }
}


provider "ncloud" {
  access_key  = var.access_key
  secret_key  = var.secret_key
  region      = var.region
  site        = var.site
  support_vpc = var.support_vpc
}
EOF
```

# Create variables.tf

기본적인 정보 및 VPC 정보를 변수로 생성

```
cat << EOF > variables.tf
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
EOF
```

## Create vpc.tf

VPC 생성을 위한 tf 파일 생성

```
cat << EOF > vpc.tf
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
EOF
```

## Create output.tf

Terraform Remote State 사용을 위해 output.tf 파일 생성

```
cat << EOF > output.tf
output "vpc_id" {
  description = "VPC ID"
  value       = ncloud_vpc.vpc_t101.id
}

output "vpc_rt_public" {
  description = "VPC Public Routing Table ID"
  value       = ncloud_vpc.vpc_t101.default_public_route_table_no
}

output "vpc_rf_private" {
  description = "VPC Private Routing Table ID"
  value       = ncloud_vpc.vpc_t101.default_private_route_table_no
}

output "subnet_dev_lb_id" {
  description = "VPC Dev Subnet LB ID"
  value       = ncloud_subnet.subnet_dev_lb.id
}

output "subnet_dev_web_id" {
  description = "VPC Dev Subnet WEB ID"
  value       = ncloud_subnet.subnet_dev_web.id
}

output "subnet_stg_lb_id" {
  description = "VPC Stg Subnet LB ID"
  value       = ncloud_subnet.subnet_stg_lb.id
}

output "subnet_stg_web_id" {
  description = "VPC Stg Subnet WEB ID"
  value       = ncloud_subnet.subnet_stg_web.id
}
EOF
```

## Run terraform
Terraform 실행

```
terraform init
terraform apply --auto-approve
```