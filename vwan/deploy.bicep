param location string = resourceGroup().location

param vwanName string = 'jjvwan'
param region1Location string = 'West Europe'
param region1Suffix string = 'weu'
param region2Location string = 'Germany West Central'
param region2Suffix string = 'ger'

@secure()
param password string

// Virtual WAN
resource vwan 'Microsoft.Network/virtualWans@2020-11-01' = {
  name: vwanName
  location: location
}

//  Hub Region1
module hubModule1 'deploy-hub.bicep' = {
  name: 'HubModule1'
  params:{
    vwanName: vwanName
    hubLocation: region1Location
    hubSuffix: region1Suffix
    addressPrefixHub: '10.101.250.0/24'
    addressPrefixVnetApp1: '10.101.1.0/24'
    addressPrefixVnetApp2: '10.101.2.0/24'
    connectBR1Site: true
    adminUsername: 'jj'
    adminPassword: password
  }
}

//  Hub Region2
// module hubModule2 'deploy-hub.bicep' = {
//   name: 'HubModule2'
//   params:{
//     vwanName: vwanName
//     hubLocation: region2Location
//     hubSuffix: region2Suffix
//     addressPrefixHub: '10.102.250.0/24'
//     addressPrefixVnetApp1: '10.102.1.0/24'
//     addressPrefixVnetApp2: '10.102.2.0/24'
//     connectBR1Site: false
//     adminUsername: 'jj'
//     adminPassword: password
//   }
// }
