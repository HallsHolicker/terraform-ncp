resource "ncloud_init_script" "init_web" {
  name    = "initial-web-server"
  content = <<-EOF
              #!/bin/bash
              wget https://busybox.net/downloads/binaries/1.28.1-defconfig-multiarch/busybox-x86_64 --no-check-certificate
              mv busybox-x86_64 busybox
              chmod +x busybox
              LIP=$(hostname -I)
              echo "<h1>HallsHolicker</h1> <h1> : Private IP($LIP) : Web Server</h1>" > index.html
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
