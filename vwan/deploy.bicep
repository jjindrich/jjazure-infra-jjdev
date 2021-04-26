param location string = resourceGroup().location

@description('Specify Azure Virtual WAN name.')
param vwanName string = 'jjvwan'

resource vwan 'Microsoft.Network/virtualWans@2020-11-01' = {
  name: vwanName
  location: location
}

resource hubWeu 'Microsoft.Network/virtualHubs@2020-11-01' = {
  name: 'jjvwan-weu'
  location: 'westeurope'  
  properties:{
    virtualWan:{
      id: vwan.id
    }
    sku: 'Standard'
    addressPrefix: '10.101.250.0/24'
    allowBranchToBranchTraffic: true
  }
}

resource hubNeu 'Microsoft.Network/virtualHubs@2020-11-01' = {
  name: 'jjvwan-neu'
  location: 'northeurope'  
  properties:{
    virtualWan:{
      id: vwan.id
    }
    sku: 'Standard'
    addressPrefix: '10.102.250.0/24'
    allowBranchToBranchTraffic: true
  }
}

resource hubGer 'Microsoft.Network/virtualHubs@2020-11-01' = {
  name: 'jjvwan-ger'
  location: 'germanywestcentral'  
  properties:{
    virtualWan:{
      id: vwan.id
    }
    sku: 'Standard'
    addressPrefix: '10.103.250.0/24'
    allowBranchToBranchTraffic: true
  }
}
