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
