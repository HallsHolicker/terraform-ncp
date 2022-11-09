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
