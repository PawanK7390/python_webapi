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

  # Prevent replacement/destroy
  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      sku,
      kind,
      tags
    ]
  }
}

resource "azurerm_app_service" "app" {
  name                = "pythonwebapijenkins8387963808"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.asp.id


  app_settings = {
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
    "WEBSITES_PORT"                  = "8000"
    "STARTUP_COMMAND"                = "python app.py"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      app_settings,
      site_config[0].always_on
    ]
  }
}
