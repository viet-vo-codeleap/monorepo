resource "azurerm_container_app_environment" "main" {
  name                = "cae-${var.project}-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}

resource "azurerm_container_app" "backend" {
  name = "ca-${var.project}-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  container_app_environment_id = azurerm_container_app_environment.main.id
  revision_mode = "Single"
  template {
   container {
    name = "backend"
    image = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
    cpu = 0.25
    memory = "0.5Gi"
   } 
  }
  ingress {
    target_port = 80
    external_enabled = true 
    traffic_weight {
      percentage = 100
      latest_revision = true
    }
  }
}