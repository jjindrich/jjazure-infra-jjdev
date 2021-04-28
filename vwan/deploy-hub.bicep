param vwanName string
param hubLocation string
param hubSuffix string
param addressPrefixHub string
param addressPrefixVnetApp1 string
param addressPrefixVnetApp2 string
@secure()
param adminPassword string

// reference existing vWan
resource vwan 'Microsoft.Network/virtualWans@2020-11-01' existing = {
  name: vwanName
}

// Virtual HUB and spokes - Region1
resource hubWeu 'Microsoft.Network/virtualHubs@2020-11-01' = {
  name: '${vwanName}-${hubSuffix}' 
  location: hubLocation
  properties:{
    virtualWan:{
      id: vwan.id
    }
    sku: 'Standard'
    addressPrefix: addressPrefixHub
    allowBranchToBranchTraffic: true
  }
}

// virtual network App1 and link to HUB
resource vnetWeuApp1 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: '${vwanName}-${hubSuffix}-app1'
  location: hubLocation
  properties:{
    addressSpace: {
      addressPrefixes:[
        addressPrefixVnetApp1
      ]      
    }
    subnets:[
      {
        name: 'snet-default'
        properties:{
          addressPrefix: addressPrefixVnetApp1
        }
      }
    ]
  }
}
resource connectionWeuApp1 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2020-11-01' = {
  name: '${vwanName}-${hubSuffix}-app1'
  parent: hubWeu
  properties:{
    remoteVirtualNetwork:{
      id: vnetWeuApp1.id
    }
  }
}

// virtual network App2 and link to HUB
resource vnetWeuApp2 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: '${vwanName}-${hubSuffix}-app2'
  location: hubLocation
  properties:{
    addressSpace: {
      addressPrefixes:[
        addressPrefixVnetApp2
      ]      
    }
    subnets:[
      {
        name: 'snet-default'
        properties:{
          addressPrefix: addressPrefixVnetApp2
        }
      }
    ]
  }
}
resource connectionWeuApp2 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2020-11-01' = {
  name: '${vwanName}-${hubSuffix}-app2'
  parent: hubWeu
  properties:{
    remoteVirtualNetwork:{
      id: vnetWeuApp2.id
    }
  }
}

// VM in App1 vnet
resource vmApp1Nic 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: '${vwanName}-${hubSuffix}-app1-vm1-nic'
  location: hubLocation
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: vnetWeuApp1.properties.subnets[0].id
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}
resource vmApp1 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: '${vwanName}-${hubSuffix}-app1-vm1'
  location: hubLocation
  properties: {
    osProfile: {
      computerName: '${vwanName}-${hubSuffix}-app1-vm1'
      adminUsername: 'jj'
      adminPassword: adminPassword
      linuxConfiguration: {        
        disablePasswordAuthentication: false
      }
    }
    hardwareProfile: {
      vmSize: 'Standard_B1ms'
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        name: '${vwanName}-${hubSuffix}-app1-vm1-osdisk'
      }
      dataDisks: []
    }
    networkProfile: {
      networkInterfaces: [
        {
          properties: {
            primary: true
          }
          id: vmApp1Nic.id
        }
      ]
    }
  }
}
