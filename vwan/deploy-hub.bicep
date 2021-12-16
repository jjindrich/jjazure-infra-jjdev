param vwanName string
param hubLocation string
param hubSuffix string
param addressPrefixHub string
param addressPrefixVnetApp1 string
param addressPrefixVnetApp2 string
param connectBR1Site bool
@secure()
param adminUsername string
@secure()
param adminPassword string

// reference existing vWan
resource vwan 'Microsoft.Network/virtualWans@2020-11-01' existing = {
  name: vwanName
}

// Virtual HUB
resource hub 'Microsoft.Network/virtualHubs@2020-11-01' = {
  name: '${vwanName}-${hubSuffix}'
  location: hubLocation
  properties: {
    virtualWan: {
      id: vwan.id
    }
    sku: 'Standard'
    addressPrefix: addressPrefixHub
    allowBranchToBranchTraffic: true
  }
}

// VPN GW in HUB
resource vpnGw 'Microsoft.Network/vpnGateways@2021-03-01' = {
  name: '${vwanName}-vpnGw'
  location: hubLocation
  properties: {
    virtualHub: {
      id: hub.id
    }    
  }
}

// VPN link and connect into JJBR1
resource vpnLinkBr1 'Microsoft.Network/vpnSites@2021-03-01' = if (connectBR1Site){
  name: '${vwanName}-jjbr1'
  location: hubLocation
  properties: {
    virtualWan: {
      id: vwan.id
    }
    deviceProperties: {
      deviceVendor: 'WindowsServer'
    }
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
    vpnSiteLinks: [
      {
        name: 'BR1-office'
        properties:{
          ipAddress: '194.213.40.56'
          linkProperties:{
            linkProviderName: 'MS-office'
            linkSpeedInMbps: 10
          }
        }
      }
    ]
  }
}
resource vpnLinkBr1Conn 'Microsoft.Network/vpnGateways/vpnConnections@2021-03-01' = if (connectBR1Site) {
  name: '${vwanName}-vpnGw-jjbr1'
  parent: vpnGw
  properties: {
    remoteVpnSite: {
      id: vpnLinkBr1.id
    }
    vpnLinkConnections:[
      {
        name: '${vwanName}-vpnGw-jjbr1'
        properties:{
          sharedKey: 'abc123'
          vpnConnectionProtocolType: 'IKEv2'
          connectionBandwidth: 10
          vpnSiteLink: {
            id: vpnLinkBr1.properties.vpnSiteLinks[0].id
          }
        }
      }
    ]
  }
}

// virtual network App1 and link to HUB
resource vnetApp1 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: '${vwanName}-${hubSuffix}-app1'
  location: hubLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefixVnetApp1
      ]
    }
    subnets: [
      {
        name: 'snet-default'
        properties: {
          addressPrefix: addressPrefixVnetApp1
        }
      }
    ]
  }
}
resource connectionApp1 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2020-11-01' = {
  name: '${vwanName}-${hubSuffix}-app1'
  parent: hub
  properties: {
    remoteVirtualNetwork: {
      id: vnetApp1.id
    }
  }
}

// virtual network App2 and link to HUB
resource vnetApp2 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: '${vwanName}-${hubSuffix}-app2'
  location: hubLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefixVnetApp2
      ]
    }
    subnets: [
      {
        name: 'snet-default'
        properties: {
          addressPrefix: addressPrefixVnetApp2
        }
      }
    ]
  }
}
resource connectionApp2 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2020-11-01' = {
  name: '${vwanName}-${hubSuffix}-app2'
  parent: hub
  properties: {
    remoteVirtualNetwork: {
      id: vnetApp2.id
    }
  }
}

// VM in App1 vnet
resource vmApp1Nic 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: '${vwanName}-${hubSuffix}-app1-vm1-nic'
  location: hubLocation
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: vnetApp1.properties.subnets[0].id
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}
resource vmApp1 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: '${vwanName}-${hubSuffix}-app1-vm1'
  location: hubLocation
  properties: {
    osProfile: {
      computerName: '${vwanName}-${hubSuffix}-app1-vm1'
      adminUsername: adminUsername
      adminPassword: adminPassword
      linuxConfiguration: {
        disablePasswordAuthentication: false
      }
    }
    hardwareProfile: {
      vmSize: 'Standard_B1ms'
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        name: '${vwanName}-${hubSuffix}-app1-vm1-osdisk'
      }
      dataDisks: []
    }
    networkProfile: {
      networkInterfaces: [
        {
          properties: {
            primary: true
          }
          id: vmApp1Nic.id
        }
      ]
    }
  }
}
