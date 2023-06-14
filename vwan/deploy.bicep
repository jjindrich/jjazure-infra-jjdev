param location string = resourceGroup().location

param vwanName string = 'jjazvwan'
param region1Location string = 'West Europe'
param region1Suffix string = 'weu'
param region2Location string = 'North Europe'
param region2Suffix string = 'neu'
param region3Location string = 'Sweden Central'
param region3Suffix string = 'swe'

@secure()
param password string

// Virtual WAN
resource vwan 'Microsoft.Network/virtualWans@2020-11-01' = {
  name: vwanName
  location: location
}

// ----------------------------------------------------------
// ------------------------ Region 1 ------------------------
// ----------------------------------------------------------

//  Hub Region1 with VPN
module hub1 'deploy-hubfull.bicep' = {
  name: 'Hub1'
  params: {
    vwanName: vwanName
    hubLocation: region1Location
    hubSuffix: region1Suffix
    addressPrefixHub: '10.101.250.0/24'
    secureHub: true
  }
}

// Vnets conneted to Hub1: app1, app2
module hub1Vnet1 'deploy-vnet.bicep' = {
  name: 'Hub1Vnet1'
  params: {
    hubName: hub1.outputs.hubName
    vnetName: 'app1'
    addressPrefixVnet: '10.101.1.0/24'
    location: region1Location
  }
}
module hub1Vnet2 'deploy-vnet.bicep' = {
  name: 'Hub1Vnet2'
  params: {
    hubName: hub1.outputs.hubName
    vnetName: 'app2'
    addressPrefixVnet: '10.101.2.0/24'
    location: region1Location
  }
}

//VMs
module hub1App1Vm1 'deploy-vm.bicep' = {
  name: 'hub1App1Vm1'
  params: {
    vnetName: hub1Vnet1.outputs.vnetName
    subnetName: hub1Vnet1.outputs.subnetName
    vmName: '${hub1Vnet1.outputs.vnetName}-vm1'
    adminUsername: 'jj'
    adminPassword: password
    location: region1Location
  }
}
module hub1App2Vm1 'deploy-vm.bicep' = {
  name: 'hub1App2Vm1'
  params: {
    vnetName: hub1Vnet2.outputs.vnetName
    subnetName: hub1Vnet2.outputs.subnetName
    vmName: '${hub1Vnet2.outputs.vnetName}-vm1'
    adminUsername: 'jj'
    adminPassword: password
    location: region1Location
  }
}

// ----------------------------------------------------------
// ------------------------ Region 2 ------------------------
// ----------------------------------------------------------
//  Hub Region2
module hub2 'deploy-hub.bicep' = {
  name: 'Hub2'
  params: {
    vwanName: vwanName
    hubLocation: region2Location
    hubSuffix: region2Suffix
    addressPrefixHub: '10.102.250.0/24'
    secureHub: true
  }
}

// Vnets conneted to Hub1: app1
module hub2Vnet1 'deploy-vnet.bicep' = {
  name: 'Hub2Vnet1'
  params: {
    hubName: hub2.outputs.hubName
    vnetName: 'app1'
    addressPrefixVnet: '10.102.1.0/24'
    location: region2Location
  }
}

//VMs
module hub2App1Vm1 'deploy-vm.bicep' = {
  name: 'hub2App1Vm1'
  params: {
    vnetName: hub2Vnet1.outputs.vnetName
    subnetName: hub2Vnet1.outputs.subnetName
    vmName: '${hub2Vnet1.outputs.vnetName}-vm1'
    adminUsername: 'jj'
    adminPassword: password
    location: region2Location
  }
}

// ----------------------------------------------------------
// ------------------------ Region 3 ------------------------
// ----------------------------------------------------------
//  Hub Region3
module hub3 'deploy-hub.bicep' = {
  name: 'Hub3'
  params: {
    vwanName: vwanName
    hubLocation: region3Location
    hubSuffix: region3Suffix
    addressPrefixHub: '10.103.250.0/24'
    secureHub: false
  }
}

// Vnets conneted to Hub1: app1
module hub3Vnet1 'deploy-vnet.bicep' = {
  name: 'Hub3Vnet1'
  params: {
    hubName: hub3.outputs.hubName
    vnetName: 'app1'
    addressPrefixVnet: '10.103.1.0/24'
    location: region3Location
  }
}

//VMs
module hub3App1Vm1 'deploy-vm.bicep' = {
  name: 'hub3App1Vm1'
  params: {
    vnetName: hub3Vnet1.outputs.vnetName
    subnetName: hub3Vnet1.outputs.subnetName
    vmName: '${hub3Vnet1.outputs.vnetName}-vm1'
    adminUsername: 'jj'
    adminPassword: password
    location: region3Location
  }
}
