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
