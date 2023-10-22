resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = "${var.resource_group_name_prefix}-streamlit-test"
}

resource "azurerm_container_registry" "acr" {
  name                          = "${var.project_name}acr"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = var.resource_group_location
  sku                           = "Basic"
  admin_enabled                 = true
  public_network_access_enabled = true

}

resource "null_resource" "docker_push" {
  triggers = {
    email_list_sha = sha256(timestamp())
  }
  depends_on = [azurerm_container_registry.acr]

  provisioner "local-exec" {
    command = <<-EOT
      ./push_docker.sh
    EOT
  }
}

# resource "azurerm_container_group" "container" {
#   name                = "${var.container_group_name_prefix}-${var.project_name}"
#   location            = var.resource_group_location
#   resource_group_name = azurerm_resource_group.rg.name
#   ip_address_type     = "Public"
#   os_type             = "Linux"
#   restart_policy      = var.restart_policy

#   exposed_port {
#     port     = var.port
#     protocol = "TCP"
#   }

#   image_registry_credential {
#     username = azurerm_container_registry.acr.admin_username
#     password = azurerm_container_registry.acr.admin_password
#     server   = azurerm_container_registry.acr.login_server
#   }

#   container {
#     name   = "${var.container_name_prefix}-${var.project_name}"
#     image  = "${azurerm_container_registry.acr.login_server}/${var.image_name}:latest"
#     cpu    = var.cpu_cores
#     memory = var.memory_in_gb

#     ports {
#       port     = var.port
#       protocol = "TCP"
#     }
#   }
# }


# Create the Linux App Service Plan
resource "azurerm_service_plan" "appserviceplan" {
  name                = "webapp-asp-${var.project_name}"
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B1" # Free tier
}

# Create the web app, pass in the App Service Plan ID
resource "azurerm_linux_web_app" "webapp" {
  name                = "webapp-${var.project_name}"
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.appserviceplan.id
  https_only          = true
  site_config {
    minimum_tls_version = "1.2"
    # linux_fx_version   = "DOCKER|${azurerm_container_registry.acr.login_server}/${var.image_name}:latest"
    health_check_path = "/health"
    # always_on             = false
    # container_registry_use_managed_identity = true
    # container_registry_managed_identity_client_id = azurerm_user_assigned_identity.id.client_id
    application_stack {
      docker_image_name        = "${var.image_name}:latest"
      docker_registry_url      = "https://${azurerm_container_registry.acr.login_server}"
      docker_registry_username = azurerm_container_registry.acr.admin_username
      docker_registry_password = azurerm_container_registry.acr.admin_password
    }
  }
  # lifecycle {
  #   ignore_changes = [
  #     # site_config.0.application_stack.0.docker_registry_url
  #     site_config.0.linux_fx_version
  #   ]
  # }
  identity {
    type = "SystemAssigned"
    #  identity_ids = [azurerm_user_assigned_identity.id.id]
  }
  app_settings = {
    "DOCKER_REGISTRY_SERVER_PASSWORD" = azurerm_container_registry.acr.admin_password
    "DOCKER_REGISTRY_SERVER_URL"      = azurerm_container_registry.acr.login_server
    "DOCKER_REGISTRY_SERVER_USERNAME" = azurerm_container_registry.acr.admin_username

  }
}


# resource "azurerm_user_assigned_identity" "id" {
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = var.resource_group_location
#   name = "id-api-${var.project_name}"
# }

# resource "azurerm_role_assignment" "acrpull_role" {
#   scope                = azurerm_container_registry.acr.id
#   role_definition_name = "AcrPull"
#   principal_id         = azurerm_user_assigned_identity.id.principal_id
# }
