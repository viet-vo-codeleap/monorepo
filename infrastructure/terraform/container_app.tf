# Log Analytics Workspace for Container App logs
resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-${var.project}-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "main" {
  name                       = "cae-${var.project}-${var.environment}"
  resource_group_name        = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
}

# ACR data source
data "azurerm_container_registry" "acr" {
  name                = "acrvietvoneovaude"
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_container_app" "backend" {
  name                         = "ca-${var.project}-${var.environment}"
  resource_group_name          = azurerm_resource_group.main.name
  container_app_environment_id = azurerm_container_app_environment.main.id
  revision_mode                = "Single"

  # ACR registry configuration
  registry {
    server               = data.azurerm_container_registry.acr.login_server
    username             = data.azurerm_container_registry.acr.admin_username
    password_secret_name = "acr-password"
  }

  secret {
    name  = "acr-password"
    value = data.azurerm_container_registry.acr.admin_password
  }

  template {
    min_replicas = 1
    container {
      name   = "backend"
      image  = "${data.azurerm_container_registry.acr.login_server}/sample-dotnet-8:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  ingress {
    target_port      = 8080
    external_enabled = true
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  # Let CI/CD pipeline manage the image tag
  lifecycle {
    ignore_changes = [
      template[0].container[0].image
    ]
  }
}
