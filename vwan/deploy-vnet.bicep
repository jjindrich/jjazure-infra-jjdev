param hubName string
param location string
param vnetName string
param addressPrefixVnet string

// reference Virtual Hub
resource hub 'Microsoft.Network/virtualHubs@2020-11-01' existing = {
  name: hubName
}

// virtual network App1 and link to HUB
resource vnetApp 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: '${hubName}-${vnetName}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefixVnet
      ]
    }
    subnets: [
      {
        name: 'snet-default'
        properties: {
          addressPrefix: addressPrefixVnet
        }
      }
    ]
  }
}
resource connectionApp 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2020-11-01' = {
  name: '${hubName}-${vnetName}'
  parent: hub
  properties: {
    remoteVirtualNetwork: {
      id: vnetApp.id
    }
  }
}

output vnetName string = vnetApp.name
output subnetName string = vnetApp.properties.subnets[0].name

