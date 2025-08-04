provider "azurerm" {
  features{}
}

data "azurerm_resource_group" "rg" {
  name     = "DevOps_group"
}

resource "azurerm_container_group" "aci" {
  name                = "eshoponweb"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  os_type             = "Linux"

  container {
    name   = "eshoponweb"
    image  = "dang12394/eshoponweb:latest"
    cpu    = "0.1"
    memory = "0.3"

    ports {
      port     = 80
      protocol = "TCP"
    }

    environment_variables = {
      ASPNETCORE_URLS = "http://+:80"
    }
  }

  ip_address_type = "Public"
  dns_name_label  = "eshoponweb${random_integer.rand.result}"
}

resource "random_integer" "rand" {
  min = 1000
  max = 9999
}