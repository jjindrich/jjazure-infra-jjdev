param vnetHubName string = 'JJDevV2Network'
param vnetAppName string = 'JJDevV2NetworkApp'
param publicIpPrefixName string = 'jjdevv2network-pip'
param vpnGwName string = 'jjdevv2vpngw'
param bastionName string = 'jjdevv2bastion'
param location string = resourceGroup().location

resource publicIpPrefix 'Microsoft.Network/publicIPPrefixes@2019-11-01' = {
  name: publicIpPrefixName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    prefixLength: 30
    publicIPAddressVersion: 'IPv4'
  }
}

/*
******** HUB NETWORK ********
*/
resource nsgDmzInfra 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: '${vnetHubName}-DmzInfra'
  location: location
  properties: {
    securityRules: [
      {
        name: 'RDP'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '95.85.255.10'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 300
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'AdminCenter-Preview'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: [
            '6516'
          ]
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
          sourcePortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
    ]
  }
}

resource nsgAppGwSubnet 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: '${vnetHubName}-AppGwSubnet'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AppGw-ManagementV2'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '65200-65535'
          sourceAddressPrefix: 'GatewayManager'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1000
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'HTTP'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: [
            '80'
            '8080'
          ]
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 300
          direction: 'Inbound'
          sourcePortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'HTTPS'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 301
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
    ]
  }
}

resource nsgApiMngmtSubnet 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: '${vnetHubName}-ApiMngmtSubnet'
  location: location
  properties: {
    securityRules: [
      {
        name: 'ApiMngmt-magagement'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '3443'
          sourceAddressPrefix: 'ApiManagement'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 300
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
    ]
  }
}

resource nsgBastionSubnet 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: '${vnetHubName}-BastionSubnet'
  location: location
  properties: {
    securityRules: [
      {
        name: 'BastionManagement'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'GatewayManager'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 310
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'Https'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 300
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'RDP'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 110
          direction: 'Outbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'SSH'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 120
          direction: 'Outbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'DiagnosticsAndLogging'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'AzureCloud'
          access: 'Allow'
          priority: 130
          direction: 'Outbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
    ]
  }
}

resource vnetHub 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: vnetHubName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.3.0.0/16'
      ]
    }
    dhcpOptions: {
      dnsServers: []
    }
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '10.3.0.0/27'
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'DmzInfra'
        properties: {
          addressPrefix: '10.3.250.0/24'
          networkSecurityGroup: {
            id: nsgDmzInfra.id
          }
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'DmzApiMngmt'
        properties: {
          addressPrefix: '10.3.251.0/24'
          networkSecurityGroup: {
            id: nsgApiMngmtSubnet.id
          }
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '10.3.252.0/24'
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'AzureApplicationGatewaySubnet'
        properties: {
          addressPrefix: '10.3.253.0/24'
          networkSecurityGroup: {
            id: nsgAppGwSubnet.id
          }
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.3.254.0/26'
          networkSecurityGroup: {
            id: nsgBastionSubnet.id
          }
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'DmzDns-In'
        properties: {
          addressPrefix: '10.3.254.128/28'
          serviceEndpoints: []
          delegations: [
            {
              name: 'Microsoft.Network.dnsResolvers'
              properties: {
                serviceName: 'Microsoft.Network/dnsResolvers'
              }
            }
          ]
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'DmzDns-Out'
        properties: {
          addressPrefix: '10.3.254.144/28'
          serviceEndpoints: []
          delegations: [
            {
              name: 'Microsoft.Network.dnsResolvers'
              properties: {
                serviceName: 'Microsoft.Network/dnsResolvers'
              }
            }
          ]
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    enableDdosProtection: false
    enableVmProtection: false
  }
}
resource vnetHub_to_vnetApp 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2019-11-01' = {
  parent: vnetHub
  name: 'to-${vnetAppName}'
  properties: {
    remoteVirtualNetwork: {
      id: vnetApp.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: true
    useRemoteGateways: false
    remoteAddressSpace: {
      addressPrefixes: [
        '10.4.0.0/16'
      ]
    }
  }
}

/*
******** DNS Resolver as DNS server *******
  - for spoke as DNS server
  - configured forwarding to Windows AD server 
*/
resource vnetDnsResolver 'Microsoft.Network/dnsResolvers@2020-04-01-preview' = {
  name: '${vnetHubName}-dnsresolver'
  location: location
  properties:{
    virtualNetwork: {
      id: vnetHub.id
    }    
  }
}

resource subnetDnsIn 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' existing = {
  parent: vnetHub
  name: 'DmzDns-In'
}
resource vnetDnsResolverIn 'Microsoft.Network/dnsResolvers/inboundEndpoints@2020-04-01-preview' = {
  parent: vnetDnsResolver
  name: '${vnetHubName}-dnsresolver-in'
  location: location
  properties: {
    ipConfigurations: [
      {
        subnet: {
          id: subnetDnsIn.id
        }        
      }
    ]
  }
}

resource subnetDnsOut 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' existing = {
  parent: vnetHub
  name: 'DmzDns-Out'
}
resource vnetDnsResolverOut 'Microsoft.Network/dnsResolvers/outboundEndpoints@2020-04-01-preview' = {
  parent: vnetDnsResolver
  name: '${vnetHubName}-dnsresolver-out'
  location: location
  properties: {
    subnet: {
      id: subnetDnsOut.id
    }
  }
}

resource vnetDnsFwdRuleSet 'Microsoft.Network/dnsForwardingRulesets@2020-04-01-preview' = {
  name: '${vnetHubName}-dnsfwd'
  location: location
  properties: {
    dnsResolverOutboundEndpoints: [
      {
        id: vnetDnsResolverOut.id
      }
    ]
  }
}
resource vnetDnsResolverForwarding 'Microsoft.Network/dnsForwardingRulesets/forwardingRules@2020-04-01-preview' = {
  name: '${vnetHubName}-dnsfwd-jjdevorg'  
  parent: vnetDnsFwdRuleSet
  properties: {
    domainName: 'jjdev.org.'
    targetDnsServers: [
      {
        ipAddress: '10.3.250.10'
      }
    ]
    forwardingRuleState: 'Enabled'
  }
}
resource vnetDnsResolverForwardingLink 'Microsoft.Network/dnsForwardingRulesets/virtualNetworkLinks@2020-04-01-preview' = {
  name: '${vnetHubName}-dnsfwd-link-hub'  
  parent: vnetDnsFwdRuleSet
  properties: {
    virtualNetwork: {
      id: vnetHub.id
    }
  }
}

/*
******** HUB VPN Gateway with connection JJDevBR1 *******
*/
resource subnetVpnGw 'Microsoft.Network/virtualNetworks/subnets@2020-05-01' existing = {
  parent: vnetHub
  name: 'GatewaySubnet'
}
resource ipVpnGw 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: '${vpnGwName}-ip'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  zones: [
    '1'
    '2'
    '3'
  ]
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    ipTags: []
    publicIPPrefix: {
      id: publicIpPrefix.id
    }
  }
}
resource vpnGw 'Microsoft.Network/virtualNetworkGateways@2021-05-01' = {
  name: vpnGwName
  location: location
  properties: {
    sku: {
      name: 'VpnGw1AZ'
      tier: 'VpnGw1AZ'
    }
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    ipConfigurations:[
      {
        name: 'default'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetVpnGw.id
          }
          publicIPAddress: {
            id: ipVpnGw.id
          }
        }
      }
    ]
    enableBgp: true
    bgpSettings: {
      asn: 65515
    }
  }
}
resource localVpnSite 'Microsoft.Network/localNetworkGateways@2021-05-01' = {
  name: 'JJDevBR1'
  location: location
  properties:{
    gatewayIpAddress: '194.213.40.56'
    bgpSettings: {
      asn: 65100
      bgpPeeringAddress: '10.1.0.10'
    }
    localNetworkAddressSpace: {
      addressPrefixes: [
          '10.1.0.10/32'
      ]
    }
  }
}
resource connVpn 'Microsoft.Network/connections@2021-05-01' = {
  name: 'JJDevBR1-to-${vpnGwName}'
  location: location
  properties: {
    connectionType: 'IPsec'
    connectionProtocol: 'IKEv2'
    sharedKey: 'abc123'
    enableBgp: true
    virtualNetworkGateway1: {
      id: vpnGw.id
      properties: {}
    }
    localNetworkGateway2: {
      id: localVpnSite.id
      properties: {}
    }
  }
}

/*
******** APP SPOKE NETWORK ********
*/
resource nsgAppDefault 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: '${vnetAppName}-Default'
  location: location
  properties: {
    securityRules: []
  }
}

resource nsgAppAks 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: '${vnetAppName}-AKS'
  location: location
  properties: {
    securityRules: [
      {
        name: 'HTTP'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: 'AzureFrontDoor.Backend'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 300
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'HTTPS'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 310
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
    ]
  }
}

resource vnetApp 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: vnetAppName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.4.0.0/16'
      ]
    }
    dhcpOptions: {
      dnsServers: [
        vnetDnsResolverIn.properties.ipConfigurations[0].privateIpAddress
      ]
    }
    subnets: [
      {
        name: 'DmzApp'
        properties: {
          addressPrefix: '10.4.1.0/24'
          networkSecurityGroup: {
            id: nsgAppDefault.id
          }
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'DmzAks'
        properties: {
          addressPrefix: '10.4.2.0/24'
          networkSecurityGroup: {
            id: nsgAppAks.id
          }
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
      {
        name: 'DmzAksPrivate'
        properties: {
          addressPrefix: '10.4.3.0/24'
          networkSecurityGroup: {
            id: nsgAppAks.id
          }
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'DmzAse'
        properties: {
          addressPrefix: '10.4.4.0/24'
          networkSecurityGroup: {
            id: nsgAppDefault.id
          }
          serviceEndpoints: []
          delegations: [
            {
              name: 'Microsoft.Web.hostingEnvironments'
              properties: {
                serviceName: 'Microsoft.Web/hostingEnvironments'
              }
            }
          ]
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'DmzDesktop'
        properties: {
          addressPrefix: '10.4.10.0/24'
          networkSecurityGroup: {
            id: nsgAppDefault.id
          }
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'DmzFunction'
        properties: {
          addressPrefix: '10.4.21.0/24'
          networkSecurityGroup: {
            id: nsgAppDefault.id
          }
          serviceEndpoints: []
          delegations: [
            {
              name: 'delegation'
              properties: {
                serviceName: 'Microsoft.Web/serverfarms'
              }
            }
          ]
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'DmzAci'
        properties: {
          addressPrefix: '10.4.22.0/24'
          networkSecurityGroup: {
            id: nsgAppDefault.id
          }
          serviceEndpoints: []
          delegations: [
            {
              name: 'Microsoft.ContainerInstance.containerGroups'
              properties: {
                serviceName: 'Microsoft.ContainerInstance/containerGroups'
              }
            }
          ]
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    enableDdosProtection: false
    enableVmProtection: false
  }
}
resource vnetApp_to_vnetHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2019-11-01' = {
  parent: vnetApp
  name: 'to-${vnetHubName}'
  properties: {
    remoteVirtualNetwork: {
      id: vnetHub.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: true
    remoteAddressSpace: {
      addressPrefixes: [
        '10.3.0.0/16'
      ]
    }
  }
}

/*
******** Bastion ********
*/
resource ipBastion 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: '${bastionName}-ip'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  zones: [
    '1'
    '2'
    '3'
  ]
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    ipTags: []
    publicIPPrefix: {
      id: publicIpPrefix.id
    }
  }
}
resource subnetBastion 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  parent: vnetHub
  name: 'AzureBastionSubnet'
  properties: {
    addressPrefix: '10.3.254.0/26'
  }
}
resource bastion 'Microsoft.Network/bastionHosts@2021-05-01' = {
  name: bastionName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: ipBastion.id
          }
          subnet: {
            id: subnetBastion.id
          }
        }
      }
    ]
  }
}
