# Dev 설정 구성

## Create Folder

상위 폴더로 이동 후에 작업

```
cd .. && mkdir dev && cd dev
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
  default = "vm-t101-dev-web"
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

## Create acg.tf

ACG 설정을 위한 acg.tf 파일을 생성합니다.

```
cat << EOF > acg.tf
resource "ncloud_access_control_group" "acg_dev_web" {
  name        = "acg-dev-web"
  description = "Dev Web ACG"
  vpc_no      = data.terraform_remote_state.vpc_t101.outputs.vpc_id
}

resource "ncloud_access_control_group_rule" "acg_rule_dev_web" {
  access_control_group_no = ncloud_access_control_group.acg_dev_web.id

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
resource "ncloud_network_interface" "nic_dev_web" {
  count                 = var.web_server_count
  subnet_no             = data.terraform_remote_state.vpc_t101.outputs.subnet_dev_web_id
  access_control_groups = [ncloud_access_control_group.acg_dev_web.id]
}


resource "ncloud_server" "dev_web" {
  count                     = var.web_server_count
  name                      = format("%s-%s", var.web_server_name, count.index)
  server_image_product_code = var.server_image_product_code
  server_product_code       = var.server_product_code
  subnet_no                 = data.terraform_remote_state.vpc_t101.outputs.subnet_dev_web_id
  login_key_name            = var.key_name

  init_script_no = ncloud_init_script.init_web.id

  network_interface {
    network_interface_no = ncloud_network_interface.nic_dev_web[count.index].id
    order                = 0
  }

}

# Assign public ip to Server
resource "ncloud_public_ip" "public_ip_web" {
  count              = length(ncloud_server.dev_web)
  server_instance_no = ncloud_server.dev_web[count.index].id
}
EOF
```

## Create Server Instance

서버 생성을 위해 terraform을 실행합니다.

```
terraform init
terraform apply --auto-approve
```

## Create lb.tf

로드밸런서를 생성하기 위한 lb.tf를 설정합니다.

dev에서는 테스트를 위한 Network loadbalancer를 생성합니다.

```
cat << EOF > lb.tf
resource "ncloud_lb" "lb_dev_web" {
  name           = "LB-Dev-Web"
  network_type   = "PUBLIC"
  type           = "NETWORK"
  subnet_no_list = [data.terraform_remote_state.vpc_t101.outputs.subnet_dev_lb_id]
}

resource "ncloud_lb_listener" "lb_listener_dev_web" {
  load_balancer_no = ncloud_lb.lb_dev_web.load_balancer_no
  protocol         = "TCP"
  port             = 80
  target_group_no  = ncloud_lb_target_group.tg_server.target_group_no
}

resource "ncloud_lb_target_group" "tg_server" {
  vpc_no = data.terraform_remote_state.vpc_t101.outputs.vpc_id

  name        = "tg-dev-web"
  target_type = "VSVR"
  protocol    = "TCP"
  port        = 80
  health_check {
    protocol       = "TCP"
    port           = 80
    cycle          = 5
    up_threshold   = 2
    down_threshold = 2
  }
  algorithm_type = "RR"
}

resource "ncloud_lb_target_group_attachment" "tg_attach_server" {
  count           = length(ncloud_server.dev_web)
  target_group_no = ncloud_lb_target_group.tg_server.target_group_no
  target_no_list  = [ncloud_server.dev_web[count.index].instance_no]

}
EOF
```

## Create output.tf

생성된 로드밸런서의 도메인 주소를 알기 위한 output.tf를 생성합니다.

```
cat > output.tf << EOF
output "LB_Web_Domain" {
  value = ncloud_lb.lb_dev_web.domain
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

LB_Web_Domain = "LB-Dev-Web-13994594-bf8355aa75bd.kr.lb.naverncp.com"
```


## Verify Test

로드밸런서 연동 및 웹 서비스가 제대로 되는지 테스트를 합니다.

테스트를 위해 앞전에 확인이 된 도메인 주소를 사용합니다.

```
curl http://LB-Dev-Web-13994594-bf8355aa75bd.kr.lb.naverncp.com
```

> output
```
<h1>HallsHolicker</h1> <h1> : Private IP(192.168.11.7 ) : Web Server</h1>
```