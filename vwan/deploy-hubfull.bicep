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

// VPN to JJBR1// // VPN link and connect into JJBR1
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
        '10.1.0.10/32'
      ]
    }
    vpnSiteLinks: [
      {
        name: 'BR1-office'
        properties:{
          ipAddress: '194.213.40.56'
          bgpProperties: {
            asn: 65100
            bgpPeeringAddress: '10.1.0.10'
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
// VPN to JJAZVnet
resource vpnLinkJJAz 'Microsoft.Network/vpnSites@2021-03-01' = {
  name: '${vwanName}-${hubSuffix}-jjaz'
  location: hubLocation
  properties: {
    virtualWan: {
      id: vwan.id
    }
    deviceProperties: {
      deviceVendor: 'Azure VPN Gateway'
    }
    addressSpace: {
      addressPrefixes: [
        '10.3.0.30/32'
      ]
    }
    vpnSiteLinks: [
      {
        name: 'JJAz'
        properties:{
          ipAddress: '20.238.219.208'
          bgpProperties: {
            asn: 64456
            bgpPeeringAddress: '10.3.0.30'
          }          
          linkProperties:{
            linkProviderName: 'JJAz'
            linkSpeedInMbps: 10            
          }
        }
      }
    ]
  }
}
resource vpnLinkJJAzConn 'Microsoft.Network/vpnGateways/vpnConnections@2021-03-01' = {
  name: '${vwanName}-${hubSuffix}-vpnGw-jjaz'
  parent: vpnGw
  properties: {
    remoteVpnSite: {
      id: vpnLinkJJAz.id
    }
    vpnLinkConnections:[
      {
        name: '${vwanName}-${hubSuffix}-vpnGw-jjaz'
        properties:{
          sharedKey: 'abc123'
          vpnConnectionProtocolType: 'IKEv2'
          connectionBandwidth: 10
          enableBgp: true
          vpnSiteLink: {
            id: vpnLinkJJAz.properties.vpnSiteLinks[0].id            
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
resource fwPolicyNetwork 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2022-11-01' = if (secureHub) {
  name: 'DefaultNetworkRuleCollectionGroup'
  parent: fwPolicy
  properties: {
    priority: 100
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        priority: 100
        name: 'Rule1'
        rules: [
        {
          ruleType: 'NetworkRule'
          name: 'JJ-icmp'
          ipProtocols: [
            'ICMP'
          ]
          sourceAddresses: [
            '*'
          ]
          destinationAddresses: [
            '*'
          ]
          destinationPorts: [
            '*'
          ]
        }
        ]
      }
    ]
  }
}

// Routing policy
resource routing 'Microsoft.Network/virtualHubs/routingIntent@2022-11-01' = if (secureHub) {
  name: '${vwanName}-${hubSuffix}-routing'
  parent: hub
  properties: {
    routingPolicies: [
      {
        destinations: [
          'Internet'
        ]
        name: 'default-internet'
        nextHop: azfw.id
      }
      {
        destinations: [
          'PrivateTraffic'
        ]
        name: 'default-private'
        nextHop: azfw.id
      }
    ]
  }
}
