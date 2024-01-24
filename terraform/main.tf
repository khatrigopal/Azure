# --- Define Variable used
variable "sme_netcore_oborlean_rg" {
  type    = string
  default = "sme_netcore_oborlean_rg"
}

variable "sme_aks_oborlean_rg" {
  type    = string
  default = "sme_aks_oborlean_rg"
}

variable "location" {
  type    = string
  default = "North Europe"
}

# --- Define de Hub Vnet
variable "hub_virtual_network" {
  type        = string
  description = "The HUB Vnet"
  default     = "sme_vnet_hub"
}

# --- Define the SPOKE Vnet
variable "aks_virtual_network" {
  type        = string
  description = "The SPOKE Vnet"
  default     = "sme_vnet_aks"
}


variable "fw_public_ip_name" {
  type    = string
  default = "management-fw01-pip"
}












variable "aks_subnet_name" {
  type    = string
  default = "aksdefault"
}

variable "aks_subnet_rt" {
  type    = string
  default = "aks-default-rt"
}





# --- Terraform Main Block

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.8"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }

  }
}

# --- Azure Resource Group
resource "azurerm_resource_group" "sme_netcore_oborlean_rg" {
  name     = var.sme_netcore_oborlean_rg
  location = var.location
}

resource "azurerm_resource_group" "sme_aks_oborlean_rg" {
  name     = var.sme_aks_oborlean_rg
  location = var.location
}

resource "azurerm_resource_group" "sme_core_oborlean_rg" {
  name     = "sme_core_oborlean_rg"
  location = var.location
}

# --- Network Security Group - Optional
#resource "azurerm_network_security_group" "example" {
#  name                = "example-security-group"
#  location            = azurerm_resource_group.resource_group.location
#  resource_group_name = azurerm_resource_group.resource_group.name
#}

# --- Azure Virtual Network
resource "azurerm_virtual_network" "hubvnet" {
  name                = var.hub_virtual_network
  location            = azurerm_resource_group.sme_netcore_oborlean_rg.location
  resource_group_name = azurerm_resource_group.sme_netcore_oborlean_rg.name
  address_space       = ["10.10.0.0/16"]
  dns_servers         = ["168.63.129.16", "8.8.8.8"]
  subnet {
     name           = "sme_vnet_hub_subnet"
     address_prefix = "10.10.1.0/24"
   }
  subnet {
     name           = "sme_vnet_appgw_subnet"
     address_prefix = "10.10.2.0/24"
  }
  
} 

resource "azurerm_subnet" "AzureFirewallSubnet" {
  name                 = "AzureFirewallSubnet"
  virtual_network_name = azurerm_virtual_network.hubvnet.name
  resource_group_name  = azurerm_resource_group.sme_netcore_oborlean_rg.name
  address_prefixes = ["10.10.3.0/24"]
}

resource "azurerm_subnet" "AzureFirewallManagementSubnet" {
  name                 = "AzureFirewallManagementSubnet"
  virtual_network_name = azurerm_virtual_network.hubvnet.name
  resource_group_name  = azurerm_resource_group.sme_netcore_oborlean_rg.name
  address_prefixes = ["10.10.4.0/24"]
}





resource "azurerm_virtual_network" "sme_vnet_aks" {
  name                = var.aks_virtual_network
  location            = azurerm_resource_group.sme_aks_oborlean_rg.location
  resource_group_name = azurerm_resource_group.sme_aks_oborlean_rg.name
  address_space       = ["10.12.0.0/16"]
  dns_servers         = ["168.63.129.16", "8.8.8.8"]
}

resource "azurerm_subnet" "sme_vnet_aks_subnet_pods" {
  name                 = "sme_vnet_aks_subnet_pods"
  virtual_network_name = azurerm_virtual_network.sme_vnet_aks.name
  resource_group_name  = azurerm_resource_group.sme_aks_oborlean_rg.name
  address_prefixes = ["10.12.3.0/24"]
  depends_on = [azurerm_virtual_network.sme_vnet_aks]
}


resource "azurerm_subnet" "sme_vnet_aks_subnet_nodes" {
  name                 = "sme_vnet_aks_subnet_nodes"
  virtual_network_name = azurerm_virtual_network.sme_vnet_aks.name
  resource_group_name  = azurerm_resource_group.sme_aks_oborlean_rg.name
  address_prefixes = ["10.12.1.0/24"]
  depends_on = [azurerm_virtual_network.sme_vnet_aks]
}

resource "azurerm_virtual_network_peering" "sme_vnet_peering_hub" {
  name                      = "sme_vnet_peering"
  resource_group_name       = azurerm_resource_group.sme_netcore_oborlean_rg.name
  virtual_network_name      = azurerm_virtual_network.hubvnet.name
  remote_virtual_network_id = azurerm_virtual_network.sme_vnet_aks.id
}

resource "azurerm_virtual_network_peering" "sme_vnet_peering_spoke" {
  name                      = "sme_vnet_peering_spoke"
  resource_group_name       = azurerm_resource_group.sme_aks_oborlean_rg.name
  virtual_network_name      = azurerm_virtual_network.sme_vnet_aks.name
  remote_virtual_network_id = azurerm_virtual_network.hubvnet.id
}


resource "azurerm_public_ip" "region1-fw01-pip" {
  name                = "region1-fw01-pip"
  resource_group_name = var.sme_netcore_oborlean_rg
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    Environment = "Production"
  }
  depends_on = [azurerm_resource_group.sme_netcore_oborlean_rg]
}

resource "azurerm_public_ip" "management-fw01-pip" {
  name                = var.fw_public_ip_name
  resource_group_name = var.sme_netcore_oborlean_rg
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  depends_on          = [azurerm_resource_group.sme_netcore_oborlean_rg]
}

resource "azurerm_firewall" "sme_oborlean_fw" {
  name                = "sme_oborlean_fw"
  location            = var.location
  resource_group_name = var.sme_netcore_oborlean_rg
  sku_tier            = "Basic"
  sku_name            = "AZFW_VNet"
  #management_ip_configuration = azurerm_public_ip.management-fw01-pip.name
  ip_configuration {
    name                 = "fw-ipconfig"
    subnet_id            = azurerm_subnet.AzureFirewallSubnet.id   #HERE
    public_ip_address_id = azurerm_public_ip.region1-fw01-pip.id
  }
  management_ip_configuration {
    name                 = "azfw_management_ip"
    subnet_id            = azurerm_subnet.AzureFirewallManagementSubnet.id
    public_ip_address_id = azurerm_public_ip.management-fw01-pip.id
  }
  firewall_policy_id = azurerm_firewall_policy.azfw_policy.id
}

# --- Azure Firewall Policy

resource "azurerm_firewall_policy" "azfw_policy" {
  name                     = "azfw-policy"
  resource_group_name      = azurerm_resource_group.sme_netcore_oborlean_rg.name
  location                 = azurerm_resource_group.sme_netcore_oborlean_rg.location
  sku                      = "Basic"
  threat_intelligence_mode = "Alert"
}

# --- Auzre Policies

resource "azurerm_firewall_policy_rule_collection_group" "prcg" {
  name               = "prcg"
  firewall_policy_id = azurerm_firewall_policy.azfw_policy.id
  priority           = 300
  network_rule_collection {
    name     = "netRc1"
    priority = 200
    action   = "Allow"
    rule {
      name                  = "allowall"
      protocols             = ["TCP"]
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["*"]
    }
  }
}

resource "azurerm_route_table" "sme_oborlean_routetable" {
  name                          = "sme_oborlean_routetable"
  location                      = azurerm_resource_group.sme_aks_oborlean_rg.location
  resource_group_name           = azurerm_resource_group.sme_aks_oborlean_rg.name
  disable_bgp_route_propagation = false

  route {
    name                   = "default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.sme_oborlean_fw.ip_configuration[0].private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "aks_subnet_association" {
  subnet_id      = azurerm_subnet.sme_vnet_aks_subnet_nodes.id
  route_table_id = azurerm_route_table.sme_oborlean_routetable.id

}


resource "azurerm_private_dns_zone" "azmk8s" {
  name                = "privatelink.northeurope.azmk8s.io"
  resource_group_name = azurerm_resource_group.sme_netcore_oborlean_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "azmk8slink" {
  name                  = "azmkslink"
  resource_group_name   = azurerm_resource_group.sme_netcore_oborlean_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.azmk8s.name
  virtual_network_id    = azurerm_virtual_network.sme_vnet_aks.id
}



resource "azurerm_private_dns_zone" "acr_io" {
  name                = "privatelink.northeurope.acr_io"
  resource_group_name = azurerm_resource_group.sme_netcore_oborlean_rg.name
}


# =======================================================
resource "azurerm_user_assigned_identity" "uami" {
  resource_group_name = azurerm_resource_group.sme_core_oborlean_rg.name
  location            = azurerm_resource_group.sme_core_oborlean_rg.location
  name = "sme_aks_oborlean_uami"
}


resource "azurerm_role_assignment" "sme_core_contributor" {
  scope                = azurerm_resource_group.sme_aks_oborlean_rg.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.uami.principal_id
}

#resource "azurerm_role_assignment" "contributor" {
#  scope                = azurerm_resource_group.sme_core_oborlean_rg.id
#  role_definition_name = "Contributor"
#  principal_id         = azurerm_user_assigned_identity.uami.id
#}

resource "azurerm_role_assignment" "dnscontributor" {
  scope                = azurerm_private_dns_zone.azmk8s.id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.uami.principal_id
}
# ==========================================================



resource "azurerm_kubernetes_cluster" "sme_oborlean_aks" {
  name                = "sme_oborlean_aks"
  location            = azurerm_resource_group.sme_aks_oborlean_rg.location
  resource_group_name = azurerm_resource_group.sme_aks_oborlean_rg.name
  dns_prefix          = "sme"
  oidc_issuer_enabled       = true
  workload_identity_enabled = true
  private_cluster_enabled = true
  private_dns_zone_id     = azurerm_private_dns_zone.azmk8s.id
  azure_active_directory_role_based_access_control {
    managed             = true
    azure_rbac_enabled  = true
    admin_group_object_ids = ["fd61ff1a-d05d-488d-a363-a09121e3444e"]
  }   

  default_node_pool {
    name           = "system"
    node_count     = 1
    vm_size        = "Standard_DS2_v2"
    vnet_subnet_id = azurerm_subnet.sme_vnet_aks_subnet_nodes.id
    pod_subnet_id = azurerm_subnet.sme_vnet_aks_subnet_pods.id
  }
  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
    service_cidr      = "10.13.1.0/24"
    dns_service_ip    = "10.13.1.10"
    
  }

  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.uami.id]
  }
  depends_on = [azurerm_private_dns_zone_virtual_network_link.azmk8slink, 
                azurerm_role_assignment.sme_core_contributor, 
                azurerm_private_dns_zone.azmk8s, 
                azurerm_firewall.sme_oborlean_fw, 
                azurerm_role_assignment.dnscontributor, 
                azurerm_route_table.sme_oborlean_routetable, 
                azurerm_subnet_route_table_association.aks_subnet_association, 
                azurerm_user_assigned_identity.uami, 
                azurerm_virtual_network_peering.sme_vnet_peering_hub,
                azurerm_virtual_network_peering.sme_vnet_peering_spoke
                ]
  }


resource "azurerm_kubernetes_cluster_node_pool" "sme_oborlean_aks" {
  name                  = "userpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.sme_oborlean_aks.id
  vm_size               = "Standard_DS2_v2"
  node_count            = 2
  pod_subnet_id = azurerm_subnet.sme_vnet_aks_subnet_pods.id
  tags = {
   Environment = "Production"
  }
}

#resource "azurerm_role_assignment" clusterAdmin" {
#  scope                = azurerm_kubernetes_cluster.sme_oborlean_aks
#  role_definition_name = "Contributor"
#  principal_id         = azurerm_user_assigned_identity.uami.principal_id
#}



















# --- Create Virtual Machine

#resource "azurerm_network_interface" "main" {
#  name                = "privatedns-nic"
#  location            = azurerm_resource_group.sme_netcore_oborlean_rg.location
#  resource_group_name = azurerm_resource_group.sme_netcore_oborlean_rg.name

#  ip_configuration {
#    name                          = "dnsserverconfiguration"
#    subnet_id                     = azurerm_virtual_network.hubvnet.sme_vnet_hub_subnet
#    private_ip_address_allocation = "Dynamic"
#  }
#}


#AICI

/*






resource "azurerm_subnet" "azurefirewallmanagement" {
  name                 = "AzureFirewallManagementSubnet"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.aksvnet.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_route_table" "aks_default_rt" {
  name                          = var.aks_subnet_rt
  location                      = azurerm_resource_group.resource_group.location
  resource_group_name           = azurerm_resource_group.resource_group.name
  disable_bgp_route_propagation = false

  route {
    name                   = "default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.region1-fw01.ip_configuration[0].private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "aks_subnet_association" {
  subnet_id      = azurerm_subnet.aksdefault.id
  route_table_id = azurerm_route_table.aks_default_rt.id

}

# --- Azure Public IP Address for Azure Firewall Outbound connectivity and Management

resource "azurerm_public_ip" "region1-fw01-pip" {
  name                = "region1-fw01-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    Environment = "Production"
  }
  depends_on = [azurerm_resource_group.resource_group]
}

resource "azurerm_public_ip" "management-fw01-pip" {
  name                = var.fw_public_ip_name
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  depends_on          = [azurerm_resource_group.resource_group]
}

# --- Azure Firewall Instance
resource "azurerm_firewall" "region1-fw01" {
  name                = "region1-fw01"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_tier            = "Basic"
  sku_name            = "AZFW_VNet"
  #management_ip_configuration = azurerm_public_ip.management-fw01-pip.name
  ip_configuration {
    name                 = "fw-ipconfig"
    subnet_id            = azurerm_subnet.azurefirewall.id
    public_ip_address_id = azurerm_public_ip.region1-fw01-pip.id
  }
  management_ip_configuration {
    name                 = "azfw_management_ip"
    subnet_id            = azurerm_subnet.azurefirewallmanagement.id
    public_ip_address_id = azurerm_public_ip.management-fw01-pip.id
  }
  firewall_policy_id = azurerm_firewall_policy.azfw_policy.id
}

# --- Azure Firewall Policy

resource "azurerm_firewall_policy" "azfw_policy" {
  name                     = "azfw-policy"
  resource_group_name      = azurerm_resource_group.resource_group.name
  location                 = azurerm_resource_group.resource_group.location
  sku                      = "Basic"
  threat_intelligence_mode = "Alert"
}

# --- Auzre Policies

resource "azurerm_firewall_policy_rule_collection_group" "prcg" {
  name               = "prcg"
  firewall_policy_id = azurerm_firewall_policy.azfw_policy.id
  priority           = 300
  network_rule_collection {
    name     = "netRc1"
    priority = 200
    action   = "Allow"
    rule {
      name                  = "allowall"
      protocols             = ["TCP"]
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["*"]
    }
  }
}

# --- Azure Kubernetes Service Cluster

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aksudr-test"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  dns_prefix          = "aksudertest-5dd"

  default_node_pool {
    name           = "system"
    node_count     = 1
    vm_size        = "Standard_DS2_v2"
    vnet_subnet_id = azurerm_subnet.aksdefault.id
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    outbound_type     = "userDefinedRouting"
    service_cidr      = "10.13.1.0/24"
    dns_service_ip    = "10.13.1.10"
  }

  identity {
    type = "UserAssigned"
    identity_ids = 
  }
  depends_on = [azurerm_firewall.region1-fw01]
}

*/
