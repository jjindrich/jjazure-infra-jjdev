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
module hub1 'deploy-hub.bicep' = {
  name: 'Hub1'
  params:{
    vwanName: vwanName
    hubLocation: region1Location
    hubSuffix: region1Suffix
    connectBR1Site: true
    addressPrefixHub: '10.101.250.0/24'
  }
}

// Vnets conneted to Hub1: app1, app2
module hub1Vnet1 'deploy-vnet.bicep' = {
  name: 'Hub1Vnet1'
  params:{
    hubName: hub1.outputs.hubName
    vnetName: 'app1'
    addressPrefixVnet: '10.101.1.0/24'
    location: region1Location
  }
}
module hub1Vnet2 'deploy-vnet.bicep' = {
  name: 'Hub1Vnet2'
  params:{
    hubName: hub1.outputs.hubName
    vnetName: 'app2'
    addressPrefixVnet: '10.101.2.0/24'
    location: region1Location
  }
}

//VMs
module app1Vm1 'deploy-vm.bicep' = {
  name: 'app1Vm1'
  params:{
    vnetName: hub1Vnet1.outputs.vnetName
    subnetName: hub1Vnet1.outputs.subnetName
    vmName: '${hub1Vnet1.outputs.vnetName}-vm1'
    adminUsername: 'jj'
    adminPassword: password
    location: region1Location
  }
}
module app2Vm1 'deploy-vm.bicep' = {
  name: 'app2Vm1'
  params:{
    vnetName: hub1Vnet2.outputs.vnetName
    subnetName: hub1Vnet2.outputs.subnetName
    vmName: '${hub1Vnet2.outputs.vnetName}-vm1'
    adminUsername: 'jj'
    adminPassword: password
    location: region1Location
  }
}
