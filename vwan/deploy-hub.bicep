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
