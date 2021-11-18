param gwName string = 'jjdevv2natgw'
param location string = 'westeurope'

param virtualNetworkName string = 'JJDevV2Network'
param publicIpPrefix string = 'jjdevv2network-pip'

// reference existing network resources
resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: virtualNetworkName
}
resource ipprefix 'Microsoft.Network/publicIPPrefixes@2021-02-01' existing = {
  name: publicIpPrefix
}
resource publicIp 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: '${gwName}-ip'
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
    dnsSettings: {
      domainNameLabel: gwName
    }
    publicIPPrefix: {
      id: ipprefix.id
    }
  }
}

resource natGw 'Microsoft.Network/natGateways@2021-03-01' = {
  name: gwName
  location: location  
  sku: {
    name: 'Standard'
  }
  properties: {
    idleTimeoutInMinutes: 4
    publicIpAddresses: [
      {
        id: publicIp.id
      }
    ]
  }  
}

