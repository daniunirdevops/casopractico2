# crear la red virtual
resource "azurerm_virtual_network" "vnet" {
  name                = var.network_name
  address_space       = ["10.0.0.0/16"] 
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "vsubnet" {
  name                 = var.subnet_name
  address_prefixes     = ["10.0.1.0/24"]
  resource_group_name  = var.resource_group_name
  # hasta que no esta creada la red virtual, no se puede crear la subred, és una dependencia implicita, le decimos a terraform que 
  # espere a que se cree la red virtual para crear la subred
  virtual_network_name = azurerm_virtual_network.vnet.name
}

# IP pública para acceder a la VM (SSH y HTTPS) desde Internet.
resource "azurerm_public_ip" "vm_pip" {
  name                = var.pip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# reglas de seguridad de red (NSG) para permitir el tráfico entrante a la VM (SSH y HTTPS)
resource "azurerm_network_security_group" "vm_nsg" {
  name                = "${var.prefix_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "HTTPS"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Crear la interfaz de red de la VM y asociarla a la subred y a la IP pública
resource "azurerm_network_interface" "vm_nic" {
  name                = "${var.prefix_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_pip.id
  }
}

# Asociar la interfaz de red de la VM al grupo de seguridad de red (NSG) para aplicar las reglas de seguridad.
resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  network_interface_id      = azurerm_network_interface.vm_nic.id
  network_security_group_id = azurerm_network_security_group.vm_nsg.id
}