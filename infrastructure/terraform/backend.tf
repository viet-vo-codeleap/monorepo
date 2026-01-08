terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "tfstatevietvo1767771713"
    container_name       = "tfstate"
    key                  = "neovaude.dev.tfstate"
  }
}