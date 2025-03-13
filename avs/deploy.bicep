param location string = resourceGroup().location
param avsName string = 'jjazscavs'

resource symbolicname 'Microsoft.AVS/privateClouds@2023-09-01' = {
  location: location
  name: avsName
  properties: {
    internet: 'Enabled'
    networkBlock: '10.41.0.0/22'
    managementCluster:{
      clusterSize: 1
    }
  }
  sku: {
    capacity: 3
    name: 'AV36'
  }
}
