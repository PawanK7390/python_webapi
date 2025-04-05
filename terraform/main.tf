provider "azurerm" {
  features {}
  subscription_id = "eea7dd66-806c-47a7-912f-2e3f1af71f5e"
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}


resource "azurerm_app_service_plan" "asp" {
  name                = var.app_service_plan_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "Linux"
    reserved = true

  sku {
    tier = "Basic"
    size = "B1"
  }
}


resource "azurerm_app_service" "app" {
  name                = var.app_service_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.asp.id

  site_config {
    linux_fx_version = "PYTHON|3.13"       # Set Python version
    always_on        = true
  }

  app_settings = {
    "WEBSITES_PORT"           = "8000",                                 # Required for FastAPI/Uvicorn
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"                          # Optional: Helps with Oryx-based build
    "STARTUP_COMMAND"         = "uvicorn main:app --host 0.0.0.0 --port 8000" # Tells Azure how to run your app
  }
}
