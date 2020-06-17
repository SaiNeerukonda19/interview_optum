provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
}

variable "locations" {
  type = list
  description = "list of locations"
  default = ["eastus", "westus"]
}


resource "azurerm_resource_group" "dev" {
  count = length(var.locations)
  name     = "my-test-candidate-${var.locations[count.index]}"
  location = "${var.location}"
}
