param vnetHubName string = 'jjazhubvnet'
param vnetHubResourceGroupName string
param vnetAppName string = 'jjazappvnet'
param vnetPrefix string = '10.4'
param location string = resourceGroup().location

resource vnetHub 'Microsoft.Network/virtualNetworks@2019-11-01' existing = {
  name: vnetHubName
  scope: resourceGroup(vnetHubResourceGroupName)
}

/*
******** APP SPOKE NETWORK ********
*/
resource nsgAppDefault 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: '${vnetAppName}-default-nsg'
  location: location
  properties: {
    securityRules: []
  }
}

resource nsgAppAks 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: '${vnetAppName}-aks-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'HTTP'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          //sourceAddressPrefix: 'AzureFrontDoor.Backend'
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
        '${vnetPrefix}.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'app-snet'
        properties: {
          addressPrefix: '${vnetPrefix}.1.0/24'
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
        name: 'aks-snet'
        properties: {
          addressPrefix: '${vnetPrefix}.2.0/24'
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
        name: 'aksprivate-snet'
        properties: {
          addressPrefix: '${vnetPrefix}.3.0/24'
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
        name: 'ase-snet'
        properties: {
          addressPrefix: '${vnetPrefix}.4.0/24'
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
        name: 'avd-snet'
        properties: {
          addressPrefix: '${vnetPrefix}.10.0/24'
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
        name: 'function-snet'
        properties: {
          addressPrefix: '${vnetPrefix}.21.0/24'
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
        name: 'aci-snet'
        properties: {
          addressPrefix: '${vnetPrefix}.22.0/24'
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
      {
        name: 'aca-snet'
        properties: {
          addressPrefix: '${vnetPrefix}.6.0/23'
          networkSecurityGroup: {
            id: nsgAppDefault.id
          }
          serviceEndpoints: []
          delegations: [
            {
              name: 'delegation'
              properties: {
                serviceName: 'Microsoft.App/environments'
              }
            }
          ]
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'appgw-snet'
        properties: {
          addressPrefix: '${vnetPrefix}.8.0/24'
          networkSecurityGroup: {
            id: nsgAppDefault.id
          }
          serviceEndpoints: []
          delegations: [
            {
              name: 'delegation'
              properties: {
                serviceName: 'Microsoft.ServiceNetworking/trafficControllers'
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
