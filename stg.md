# Stg 설정 구성

## Create Folder

상위 폴더로 이동 후에 작업

```
cd .. && mkdir stg && cd stg
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

## Create variable.tf

변수 사용을 위한 variable.tf를 생성합니다.

```
cat << EOF > variable.tf
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
EOF
```

## Create data.tf

global의 terraform 정보를 사용하기 위한 terraform remote state 설정을 합니다

```
cat << EOF > data.tf
data "terraform_remote_state" "vpc_t101" {
  backend = "local"
  config = {
    path = "../global/terraform.tfstate"
  }
}
EOF
```

## Create vpc.tf

Natgatway를 생성하기 위해 vpc.tf 파일을 만듭니다.

Natgateway 생성 및 Private route에 nat gateway를 연동합니다.

```
cat << EOF > vpc.tf
resource "ncloud_nat_gateway" "nat_t101" {
  vpc_no = data.terraform_remote_state.vpc_t101.outputs.vpc_id
  zone   = var.vpc_zone
  name   = "nat-t101"
}

resource "ncloud_route" "rt_nat" {
  route_table_no         = data.terraform_remote_state.vpc_t101.outputs.vpc_rf_private
  destination_cidr_block = "0.0.0.0/0"
  target_name            = ncloud_nat_gateway.nat_t101.name
  target_no              = ncloud_nat_gateway.nat_t101.id
  target_type            = "NATGW"
}

EOF
```

## Create Nat Gateway
Nat gateway를 생성하기 위해 terraform을 실행합니다.

```
terraform init
terraform apply --auto-approve
```


## Create acg.tf

ACG 설정을 위한 acg.tf 파일을 생성합니다.

```
cat << EOF > acg.tf
resource "ncloud_access_control_group" "acg_stg_web" {
  name        = "acg-stg-web"
  description = "stg Web ACG"
  vpc_no      = data.terraform_remote_state.vpc_t101.outputs.vpc_id
}

resource "ncloud_access_control_group_rule" "acg_rule_stg_web" {
  access_control_group_no = ncloud_access_control_group.acg_stg_web.id

  inbound {
    protocol   = "TCP"
    ip_block   = "0.0.0.0/0"
    port_range = "80"
  }

  inbound {
    protocol   = "TCP"
    ip_block   = "`curl ipinfo.io/ip`/32"
    port_range = "22"
  }

  outbound {
    protocol   = "TCP"
    ip_block   = "0.0.0.0/0"
    port_range = "1-65535"
  }
}
EOF
```

## Create server.tf

서버 생성을 위한 server.tf를 생성합니다.
서버 생성에는 약 15분 정도가 소요됩니다.

```
cat << EOF > server.tf
resource "ncloud_init_script" "init_web" {
  name    = "initial-web-server"
  content = <<-EOF
              #!/bin/bash
              wget https://busybox.net/downloads/binaries/1.28.1-defconfig-multiarch/busybox-x86_64 --no-check-certificate
              mv busybox-x86_64 busybox
              chmod +x busybox
              LIP=\$(hostname -I)
              echo "<h1>HallsHolicker</h1> <h1> : Private IP(\$LIP) : Web Server</h1>" > index.html
              nohup ./busybox httpd -f -p 80 &
              EOF
}

# Assign ACG to Nic
resource "ncloud_network_interface" "nic_stg_web" {
  count                 = var.web_server_count
  subnet_no             = data.terraform_remote_state.vpc_t101.outputs.subnet_stg_web_id
  access_control_groups = [ncloud_access_control_group.acg_stg_web.id]
}


resource "ncloud_server" "stg_web" {
  count                     = var.web_server_count
  name                      = format("%s-%s", var.web_server_name, count.index)
  server_image_product_code = var.server_image_product_code
  server_product_code       = var.server_product_code
  subnet_no                 = data.terraform_remote_state.vpc_t101.outputs.subnet_stg_web_id
  login_key_name            = var.key_name

  init_script_no = ncloud_init_script.init_web.id

  network_interface {
    network_interface_no = ncloud_network_interface.nic_stg_web[count.index].id
    order                = 0
  }

}
EOF
```

## Create Server Instance

서버 생성을 위해 terraform을 실행합니다.

```
terraform apply --auto-approve
```

## Create lb.tf

로드밸런서를 생성하기 위한 lb.tf를 설정합니다.

stg에서는 테스트를 위한 Network loadbalancer를 생성합니다.

```
cat << EOF > lb.tf
resource "ncloud_lb" "lb_stg_web" {
  name           = "LB-stg-Web"
  network_type   = "PUBLIC"
  type           = "APPLICATION"
  subnet_no_list = [data.terraform_remote_state.vpc_t101.outputs.subnet_stg_lb_id]
}

resource "ncloud_lb_listener" "lb_listener_stg_web" {
  load_balancer_no = ncloud_lb.lb_stg_web.load_balancer_no
  protocol         = "HTTP"
  port             = 80
  target_group_no  = ncloud_lb_target_group.tg_server.target_group_no
}

resource "ncloud_lb_target_group" "tg_server" {
  vpc_no = data.terraform_remote_state.vpc_t101.outputs.vpc_id

  name        = "tg-stg-web"
  target_type = "VSVR"
  protocol    = "HTTP"
  port        = 80
  health_check {
    protocol       = "HTTP"
    http_method    = "GET"
    port           = 80
    url_path       = "/"
    cycle          = 5
    up_threshold   = 2
    down_threshold = 2
  }
  algorithm_type = "RR"
}

resource "ncloud_lb_target_group_attachment" "tg_attach_server" {
  count           = length(ncloud_server.stg_web)
  target_group_no = ncloud_lb_target_group.tg_server.target_group_no
  target_no_list  = [ncloud_server.stg_web[count.index].instance_no]

}

EOF
```

## Create output.tf

생성된 로드밸런서의 도메인 주소를 알기 위한 output.tf를 생성합니다.

```
cat > output.tf << EOF
output "LB_Web_Domain" {
  value = ncloud_lb.lb_stg_web.domain
}
EOF
```

## Create Loadbalancer

로드밸런서를 생성하기 위해 terraform을 실행합니다.

```
terraform apply --auto-approve
```

> ooutput
```
Outputs:

LB_Web_Domain = "LB-stg-Web-14001103-4cc247f52f15.kr.lb.naverncp.com"
```


## Verify Test

로드밸런서 연동 및 웹 서비스가 제대로 되는지 테스트를 합니다.

테스트를 위해 앞전에 확인이 된 도메인 주소를 사용합니다.

```
curl http://LB-stg-Web-14001103-4cc247f52f15.kr.lb.naverncp.com
```

> output
```
<h1>HallsHolicker</h1> <h1> : Private IP(192.168.101.6 ) : Web Server</h1>
```