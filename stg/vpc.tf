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
