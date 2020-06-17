provider "azurerm" {
  version = "= 2.0.0"
  features {}
}

resource "azurerm_resource_group" "eastrg" {
  name = "eastus-terraform-rg"
  location = "eastus"
}

resource "azurerm_resource_group" "westrg" {
  name = "west-terraform-rg"
  location = "westus"
}

resource "azurerm_virtual_network" "myvneteast" {
  name = "my-vnet"
  address_space = ["10.2.0.0/20"]
  location = "eastus"
  resource_group_name = azurerm_resource_group.eastrg.name
}

resource "azurerm_virtual_network" "myvnetwest" {
  name = "my-vnet"
  address_space = ["10.1.0.0/20"]
  location = "westus"
  resource_group_name = azurerm_resource_group.westrg.name
}

resource "azurerm_subnet" "eastfrontendsubnet" {
  name = "frontendSubnet"
  resource_group_name =  azurerm_resource_group.eastrg.name
  virtual_network_name = azurerm_virtual_network.myvneteast.name
  address_prefix = "10.2.0.0/20"
}

resource "azurerm_subnet" "westfrontendsubnet" {
  name = "frontendSubnet"
  resource_group_name =  azurerm_resource_group.westrg.name
  virtual_network_name = azurerm_virtual_network.myvnetwest.name
  address_prefix = "10.1.0.0/20"
}

resource "azurerm_public_ip" "eastmyvm1publicip" {
  name = "pip1"
  location = "eastus"
  resource_group_name = azurerm_resource_group.eastrg.name
  allocation_method = "Dynamic"
  sku = "Basic"
}

resource "azurerm_public_ip" "westmyvm1publicip" {
  name = "pip1"
  location = "westus"
  resource_group_name = azurerm_resource_group.westrg.name
  allocation_method = "Dynamic"
  sku = "Basic"
}

resource "azurerm_network_interface" "eastmyvm1nic" {
  name = "myvm1-nic"
  location = "eastus"
  resource_group_name = azurerm_resource_group.eastrg.name

  ip_configuration {
    name = "ipconfig1"
    subnet_id = azurerm_subnet.eastfrontendsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.eastmyvm1publicip.id
  }
}


resource "azurerm_network_interface" "westmyvm1nic" {
  name = "myvm1-nic"
  location = "westus"
  resource_group_name = azurerm_resource_group.westrg.name

  ip_configuration {
    name = "ipconfig1"
    subnet_id = azurerm_subnet.frontendsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.westmyvm1publicip.id
  }
}


resource "azurerm_windows_virtual_machine" "example" {
  name                  = "myvm1"  
  location              = "eastus"
  resource_group_name   = azurerm_resource_group.easrrg.name
  network_interface_ids = [azurerm_network_interface.eastmyvm1nic.id]
  size                  = "Standard_B1s"
  admin_username        = "adminuser"
  admin_password        = "Password123!"

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  os_disk {
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

resource "azurerm_windows_virtual_machine" "example" {
  name                  = "myvm1"  
  location              = "westus"
  resource_group_name   = azurerm_resource_group.westrg.name
  network_interface_ids = [azurerm_network_interface.westmyvm1nic.id]
  size                  = "Standard_B1s"
  admin_username        = "adminuser"
  admin_password        = "Password123!"

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  os_disk {
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}
