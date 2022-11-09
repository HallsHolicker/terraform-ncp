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
