# output "server_image_code" {
#   value = format("%s => %s", data.ncloud_server_image.server_image.id, data.ncloud_server_image.server_image.product_name)
# }

# output "server_product_code" {
#   value = { for product in data.ncloud_server_products.products.server_products :
#   product.id => product.product_name }
# }


output "LB_Web_Domain" {
  value = ncloud_lb.lb_dev_web.domain
}
