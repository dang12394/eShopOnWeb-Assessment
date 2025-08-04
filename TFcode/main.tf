provider "azurerm" {
  features{}
}

resource "azurerm_resource_group" "rg" {
  name     = "DevOps_group"
  location = "Southeast Asia"
}

resource "azurerm_container_group" "aci" {
  name                = "eshoponweb"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"

  container {
    name   = "eshoponweb"
    image  = "dang12394/eshoponweb:latest"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 80
      protocol = "TCP"
    }
  }

  ip_address_type = "Public"
  dns_name_label  = "eshoponweb${random_integer.rand.result}"
}

resource "random_integer" "rand" {
  min = 1000
  max = 9999
}