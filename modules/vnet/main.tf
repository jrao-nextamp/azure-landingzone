# --------------------------------------------------------------------------
# Virtual Network
# --------------------------------------------------------------------------
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.address_space
  tags                = var.tags
}

# --------------------------------------------------------------------------
# Subnets
# --------------------------------------------------------------------------
resource "azurerm_subnet" "aca" {
  name                 = "snet-aca-${var.suffix}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_cidrs["aca"]]

  delegation {
    name = "aca"
    service_delegation {
      name    = "Microsoft.App/environments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet" "psql" {
  name                 = "snet-psql-${var.suffix}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_cidrs["psql"]]

  delegation {
    name = "psql"
    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet" "pep" {
  name                 = "snet-pep-${var.suffix}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_cidrs["pep"]]
}

resource "azurerm_subnet" "mgmt" {
  name                 = "snet-mgmt-${var.suffix}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_cidrs["mgmt"]]
}

# --------------------------------------------------------------------------
# Network Security Groups (one per subnet — default rules only)
# Delegated subnets may need specific rules: check service docs before adding.
# --------------------------------------------------------------------------
resource "azurerm_network_security_group" "nsg" {
  for_each            = toset(["aca", "psql", "pep", "mgmt"])
  name                = "nsg-${each.key}-${var.suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# --------------------------------------------------------------------------
# NSG ↔ Subnet Associations
# --------------------------------------------------------------------------
locals {
  subnet_ids = {
    aca  = azurerm_subnet.aca.id
    psql = azurerm_subnet.psql.id
    pep  = azurerm_subnet.pep.id
    mgmt = azurerm_subnet.mgmt.id
  }
}

resource "azurerm_subnet_network_security_group_association" "assoc" {
  for_each                  = local.subnet_ids
  subnet_id                 = each.value
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}
