# Container Instance setup
# output "container_ipv4_address" {
#   value = azurerm_container_group.container.ip_address
# }

output "image_name_with_tag" {
  value = "${var.image_name}:${local.new_image_tag}"
}
