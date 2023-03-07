param location string = resourceGroup().location

param virtualNetworkResourceGroupName string = 'jjnetwork-rg'
param virtualNetworkName string = 'jjazhubvnet'
param virtualNetworkSubnetName string = 'aadds-snet'

// reference existing network resources
resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: virtualNetworkName
  scope: resourceGroup(virtualNetworkResourceGroupName)
}
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  parent: vnet
  name: virtualNetworkSubnetName
}

/*
******** Azure AD Domain Services *******
*/

resource aadds 'Microsoft.AAD/domainServices@2022-12-01' = {
  name: 'jjazure.org'
  location: location
  properties: {
    domainName: 'jjazure.org'
    filteredSync: 'Disabled'
    domainConfigurationType: 'FullySynced'
    replicaSets: [
      {
        subnetId: subnet.id
        location: location
      }
    ]
    sku: 'Standard'
  }  
}
