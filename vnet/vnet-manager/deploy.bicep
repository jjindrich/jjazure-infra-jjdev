@secure()
param password string

module vnet1Module 'deploy-vnet.bicep' = {
  name: 'vnet1Module'
  params: {
    location: 'eastus'
    password: password
    vnetName: 'jjvnet1'
    vnetAddressPrefix: '10.1'
    vmjumpName: 'jjvmjump1'
  }
}

module vnet2Module 'deploy-vnet.bicep' = {
  name: 'vnet2Module'
  params: {
    location: 'eastus'
    password: password
    vnetName: 'jjvnet2'
    vnetAddressPrefix: '10.2'
    vmjumpName: 'jjvmjump2'
  }
}

module vnet3Module 'deploy-vnet.bicep' = {
  name: 'vnet3Module'
  params: {
    location: 'westeurope'
    password: password
    vnetName: 'jjvnet3'
    vnetAddressPrefix: '10.3'
    vmjumpName: 'jjvmjump3'
  }
}

module vnet4Module 'deploy-vnet.bicep' = {
  name: 'vnet4Module'
  params: {
    location: 'westeurope'
    password: password
    vnetName: 'jjvnet4'
    vnetAddressPrefix: '10.4'
    vmjumpName: 'jjvmjump4'
  }
}

// -------------------------
// Virtual network manager
// -------------------------

// create manually in portal
