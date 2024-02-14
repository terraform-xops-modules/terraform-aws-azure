resource "azurerm_resource_group" "test" {
  name     = "aws-s2s-test-tunnel-test"
  location = var.azure_location
}

resource "azurerm_network_security_group" "test" {
  name                = "aws-s2s-test-tunnel-test"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_network_security_rule" "test_ssh" {
  name                        = "SSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.test.name
  network_security_group_name = azurerm_network_security_group.test.name
}

resource "azurerm_public_ip" "test" {
  name                = "aws-s2s-test-tunnel-test"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "test" {
  name                = "aws-s2s-test-tunnel-test"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.azure_vpc.vnet_subnets_name_id["subnet1"]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.test.id
  }
}

resource "azurerm_linux_virtual_machine" "test" {
  name                  = "aws-s2s-test-tunnel-test"
  resource_group_name   = azurerm_resource_group.test.name
  location              = azurerm_resource_group.test.location
  size                  = "Standard_DS2_v2"
  admin_username        = "ubuntu"
  network_interface_ids = [azurerm_network_interface.test.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  computer_name                   = "aws-s2s-test-tunnel-test"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "ubuntu"
    public_key = file("~/.ssh/id_rsa.pub")
  }
}

output "azure_test_instance_public_ip" {
  value      = azurerm_public_ip.test.ip_address
  depends_on = [azurerm_public_ip.test]
}
