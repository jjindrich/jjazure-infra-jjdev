targetScope = 'subscription'
param location string = deployment().location

resource rgNetwork 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'jjnetwork-sc-rg'
  location: location
}
module vnet 'deploy-vnet.bicep' = {
  scope: rgNetwork
  name: 'jjazvnet'
  params:{
    location: location
    vnetHubName: 'jjazschubvnet'
    vnetAppName: 'jjazscappvnet'
    bastionName: 'jjazschub-bastion'
    vpnGwName: 'jjazschub-vpngw'
    publicIpPrefixName: 'jjazsc-pip'
  }
}
