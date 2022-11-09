data "terraform_remote_state" "vpc_t101" {
  backend = "local"
  config = {
    path = "../global/terraform.tfstate"
  }
}

# # Get Ncloud Server Image Code
# data "ncloud_server_image" "server_image" {
#   filter {
#     name   = "os_information"
#     values = ["CentOS 7.8 (64-bit)"]
#   }
# }

# # Get Ncloud Server Product Code
# data "ncloud_server_products" "products" {
#   server_image_product_code = "SW.VSVR.OS.LNX64.CNTOS.0703.B050"
#   # filter {
#   #   name   = "product_code"
#   #   values = ["SSD"]
#   #   regex  = true
#   # }

#   # filter {
#   #   name   = "cpu_count"
#   #   values = ["2"]
#   # }

#   # filter {
#   #   name   = "memory_size"
#   #   values = ["8GB"]
#   # }

#   # filter {
#   #   name   = "base_block_storage_size"
#   #   values = ["50GB"]
#   # }

#   filter {
#     name   = "product_type"
#     values = ["STAND"]
#   }
# }

