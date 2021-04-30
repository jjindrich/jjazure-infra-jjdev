param hubLocation string = 'westeurope'
param addressPrefixVnetApp1 string = '10.101.0.0/24'
param addressPrefixVnetApp2 string = '10.102.0.0/24'
@secure()
param adminPassword string


// virtual network App1 and link to HUB
resource vnetWeuApp1 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: 'jjvnet-app1'
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

// virtual network App2 and link to HUB
resource vnetWeuApp2 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: 'jjvnet-app2'
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

// VM in App1 vnet
resource vmApp1Nic 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: 'jjvnet-app1-vm1-nic'
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
  name: 'jjvnet-app1-vm1'
  location: hubLocation
  properties: {
    osProfile: {
      computerName: 'jjvnet-app1-vm1'
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
        name: 'jjvnet-app1-vm1-osdisk'
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


// VM in App2 vnet
resource vmApp2Nic 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: 'jjvnet-app2-vm1-nic'
  location: hubLocation
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: vnetWeuApp2.properties.subnets[0].id
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}
resource vmApp2 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: 'jjvnet-app2-vm1'
  location: hubLocation
  properties: {
    osProfile: {
      computerName: 'jjvnet-app2-vm1'
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
        name: 'jjvnet-app2-vm1-osdisk'
      }
      dataDisks: []
    }
    networkProfile: {
      networkInterfaces: [
        {
          properties: {
            primary: true
          }
          id: vmApp2Nic.id
        }
      ]
    }
  }
}
