targetScope = 'subscription'
param location string = 'germanywestcentral'
param locationRemote string = 'swedencentral'
@secure()
param password string

resource rgNetwork 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'jjnetwork-gw-rg'
  location: location
}
module vnetHub 'deploy-vnet-hub.bicep' = {
  scope: rgNetwork
  name: 'jjvnethub'
  params:{
    location: location
    vnetHubName: 'jjazgwhubvnet'
    vnetAppName: 'jjazgwappvnet'
    bastionName: 'jjazgwhub-bastion'
    vpnGwName: 'jjazgwhub-vpngw'
    publicIpPrefixName: 'jjazgw-pip'
  }
}
module vnetApp 'deploy-vnet-app.bicep' = {
  scope: rgNetwork
  name: 'jjvnetapp'
  params:{
    location: location
    vnetHubName: 'jjazgwhubvnet'
    vnetHubResourceGroupName: rgNetwork.name
    vnetAppName: 'jjazgwappvnet'
  }
}

resource rgVmAd 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'jjvm-ad-gw-rg'
  location: location
}
module vmAd 'deploy-vmad.bicep' = {
  scope: rgVmAd
  name: 'jjvmad'
  params:{
    location: location
    vmNamePrefix: 'jjazgwvm'
    password: password
    virtualNetworkResourceGroupName: rgNetwork.name
    virtualNetworkName: 'jjazgwhubvnet'
  }
}

resource rgNetworkRemote 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'jjnetwork-sc-rg'
  location: locationRemote
}
module vnetAppRemote 'deploy-vnet-app.bicep' = {
  scope: rgNetworkRemote
  name: 'jjvnetappremote'
  params:{
    location: locationRemote
    vnetHubName: 'jjazgwhubvnet'
    vnetHubResourceGroupName: rgNetwork.name
    vnetAppName: 'jjazscappvnet'
    vnetPrefix: '10.40'
  }
}
