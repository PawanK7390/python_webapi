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
  kind                = "Linux"
  reserved            = true # Required for Linux

  sku {
    tier = "Free"
    size = "F1"
  }
}

resource "azurerm_linux_web_app" "app" {
  name                = "pythonwebapijenkins8387963808"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_app_service_plan.asp.id

  site_config {
    application_stack {
      python_version = "3.13"
    }

    always_on = false # Not available in Free tier
  }

  app_settings = {
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
    "WEBSITES_PORT"                  = "8000"
    "STARTUP_COMMAND"                = "python app.py"
  }
}
