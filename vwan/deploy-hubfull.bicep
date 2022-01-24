param vwanName string
param hubLocation string
param hubSuffix string
param addressPrefixHub string
param secureHub bool = false

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

output hubName string = hub.name

// VPN GW in HUB
resource vpnGw 'Microsoft.Network/vpnGateways@2021-03-01' = {
  name: '${vwanName}-${hubSuffix}-vpnGw'
  location: hubLocation
  properties: {
    virtualHub: {
      id: hub.id
    }    
  }
}

// // VPN link and connect into JJBR1
resource vpnLinkBr1 'Microsoft.Network/vpnSites@2021-03-01' = {
  name: '${vwanName}-${hubSuffix}-jjbr1'
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
        '169.254.10.2/32'
      ]
    }
    vpnSiteLinks: [
      {
        name: 'BR1-office'
        properties:{
          ipAddress: '194.213.40.56'
          bgpProperties: {
            asn: 65100
            bgpPeeringAddress: '169.254.10.2'
          }          
          linkProperties:{
            linkProviderName: 'MS-office'
            linkSpeedInMbps: 10            
          }
        }
      }
    ]
  }
}
resource vpnLinkBr1Conn 'Microsoft.Network/vpnGateways/vpnConnections@2021-03-01' = {
  name: '${vwanName}-${hubSuffix}-vpnGw-jjbr1'
  parent: vpnGw
  properties: {
    remoteVpnSite: {
      id: vpnLinkBr1.id
    }
    vpnLinkConnections:[
      {
        name: '${vwanName}-${hubSuffix}-vpnGw-jjbr1'
        properties:{
          sharedKey: 'abc123'
          vpnConnectionProtocolType: 'IKEv2'
          connectionBandwidth: 10
          enableBgp: true
          vpnSiteLink: {
            id: vpnLinkBr1.properties.vpnSiteLinks[0].id            
          }
        }
      }
    ]
  }
}

// Secure Hub with Azure Firewall and policy
resource azfw 'Microsoft.Network/azureFirewalls@2020-11-01' = if (secureHub) {
  name: '${vwanName}-${hubSuffix}-Fw'
  location: hubLocation
  properties: {
    hubIPAddresses: {
      publicIPs: {
        count: 1
      }
    }
    sku: {
      name: 'AZFW_Hub'
      tier: 'Standard'
    }
    virtualHub: {
      id: hub.id      
    }
    firewallPolicy: {
      id: fwPolicy.id      
    }  
  }
}
resource fwPolicy 'Microsoft.Network/firewallPolicies@2020-11-01' = if (secureHub) {
  name: '${vwanName}-${hubSuffix}-Fw-policy'
  location: hubLocation
  properties: {
    threatIntelMode: 'Alert'
  }  
}
