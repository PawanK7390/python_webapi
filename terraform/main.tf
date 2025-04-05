provider "azurerm" {
  features {}
  subscription_id = "eea7dd66-806c-47a7-912f-2e3f1af71f5e"
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}


resource "azurerm_app_service_plan" "asp" {
  name                = "my-app-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku {
    tier = "Basic"
    size = "B1"
  }

  lifecycle {
    ignore_changes = [
      sku,  # Ignore changes to plan tier/size
      tags  # Ignore tag edits made from portal
    ]
  }
}



resource "azurerm_app_service" "app" {
  name                = "pythonwebapijenkins8387963808"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.asp.id

  site_config {
    always_on = true
  }

  lifecycle {
    ignore_changes = [
      site_config[0].always_on,  # Ignore if turned off manually
      app_settings,              # Don’t override Jenkins/CLI appsettings
    ]
  }
}

