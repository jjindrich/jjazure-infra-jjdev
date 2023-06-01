@secure()
param password string
param location string = 'westcentralus'

module vnetHubModule 'deploy-vnet.bicep' = {
  name: 'vnet3Module'
  params: {
    location: location
    password: password
    vnetName: 'jjazvnethub'
    vnetAddressPrefix: '10.100'
    vmjumpName: 'jjazvmjumphub'
  }
}

module vnetSpoke1Module 'deploy-vnet.bicep' = {
  name: 'vnet1Module'
  params: {
    location: location
    password: password
    vnetName: 'jjazvnetspoke1'
    vnetAddressPrefix: '10.1'
    vmjumpName: 'jjazvmjump1'
  }
}

module vnetSpoke2Module 'deploy-vnet.bicep' = {
  name: 'vnet2Module'
  params: {
    location: location
    password: password
    vnetName: 'jjazvnetspoke2'
    vnetAddressPrefix: '10.2'
    vmjumpName: 'jjazvmjump2'
  }
}

// -------------------------
// Virtual network manager
// -------------------------

resource vnetManager 'Microsoft.Network/networkManagers@2022-11-01' = {
  name: 'jjaznetworkmanager'
  location: location
  properties:{
    networkManagerScopes: {
      subscriptions: [
        '/subscriptions/${subscription().subscriptionId}'
      ]
    }
    networkManagerScopeAccesses: [
      'Connectivity'
      'Routing'
      'SecurityAdmin'
    ]
  }
}
resource vnetManagerGroup1 'Microsoft.Network/networkManagers/networkGroups@2022-11-01' = {
  parent: vnetManager
  name: 'jjazvnetspoke-all'
}
resource vnetManagerGroup1Member1 'Microsoft.Network/networkManagers/networkGroups/staticMembers@2022-11-01' = {
  parent: vnetManagerGroup1
  name: 'jjazvnetspoke-all-member1'
  properties: {
      resourceId : vnetSpoke1Module.outputs.vnetId
  }
}
resource vnetManagerGroup1Member2 'Microsoft.Network/networkManagers/networkGroups/staticMembers@2022-11-01' = {
  parent: vnetManagerGroup1
  name: 'jjazvnetspoke-all-member2'
  properties: {
      resourceId : vnetSpoke2Module.outputs.vnetId
  }
}
// Hub&Spoke connectivity
resource vnetManagerConnectivity 'Microsoft.Network/networkManagers/connectivityConfigurations@2022-11-01' = {
  parent: vnetManager
  name: 'jjazvnethubspoke'
  properties: {
    connectivityTopology: 'HubAndSpoke'
    deleteExistingPeering: 'true'
    hubs: [
      {
        resourceType: 'VirtualNetwork'
        resourceId: vnetHubModule.outputs.vnetId
      }
    ]
    appliesToGroups: [
      {
        networkGroupId: vnetManagerGroup1.id
        useHubGateway: 'true'
        groupConnectivity: 'None'
      }
    ]
  }
}
