data "azurerm_resource_group" "rg" {
  name = "${var.resource_group_name_prefix}-streamlit-test"
}

resource "azurerm_container_registry" "acr" {
  name                          = "${var.project_name}acr"
  resource_group_name           = data.azurerm_resource_group.rg.name
  location                      = var.resource_group_location
  sku                           = "Basic"
  admin_enabled                 = true
  public_network_access_enabled = true
}

locals {
  new_image_tag = replace(timestamp(), "/[- TZ:]/", "")
}

resource "null_resource" "docker_push" {
  triggers = {
    new_image_tag = sha256(local.new_image_tag)
  }
  depends_on = [azurerm_container_registry.acr]

  provisioner "local-exec" {
    command = <<-EOT
      ./push_docker.sh "${local.new_image_tag}"
    EOT
  }
}

# Web App Setup
resource "azurerm_service_plan" "appserviceplan" {
  name                = "webapp-asp-${var.project_name}"
  location            = var.resource_group_location
  resource_group_name = data.azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B1" # Free tier
}

resource "azurerm_linux_web_app" "webapp" {
  name                = "webapp-${var.project_name}"
  location            = var.resource_group_location
  resource_group_name = data.azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.appserviceplan.id
  https_only          = true
  site_config {
    minimum_tls_version = "1.2"
    health_check_path   = "/health"
    application_stack {
      docker_image_name        = "${var.image_name}:${local.new_image_tag}"
      docker_registry_url      = "https://${azurerm_container_registry.acr.login_server}"
      docker_registry_username = azurerm_container_registry.acr.admin_username
      docker_registry_password = azurerm_container_registry.acr.admin_password
    }
  }
  identity {
    type = "SystemAssigned"
  }
  app_settings = {
    "DOCKER_REGISTRY_SERVER_PASSWORD" = azurerm_container_registry.acr.admin_password
    "DOCKER_REGISTRY_SERVER_URL"      = azurerm_container_registry.acr.login_server
    "DOCKER_REGISTRY_SERVER_USERNAME" = azurerm_container_registry.acr.admin_username

  }
}

# Azure Container Instance Setup
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
