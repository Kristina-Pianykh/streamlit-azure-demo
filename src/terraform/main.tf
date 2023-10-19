resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = "${var.resource_group_name_prefix}-streamlit-test"
}

resource "azurerm_container_registry" "acr" {
  name                = "${var.project_name}acr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.resource_group_location
  sku                 = "Basic"
  admin_enabled       = false
  public_network_access_enabled = true
}

