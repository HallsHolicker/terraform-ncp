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

  # inbound {
  #   protocol   = "TCP"
  #   ip_block   = "0.0.0.0/0"
  #   port_range = "22"
  # }

  outbound {
    protocol   = "TCP"
    ip_block   = "0.0.0.0/0"
    port_range = "1-65535"
  }
}
