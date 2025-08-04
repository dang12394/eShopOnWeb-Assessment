terraform {
  required_version = "~> 1.12.2"
  backend "azurerm" {
    resource_group_name  = "DevOps_group"
    storage_account_name = "tfstatestore12394"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}