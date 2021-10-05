param location string = 'eastus'
param location2 string = 'westeurope'
@secure()
param password string

// ------------------
// Virtual networks
// ------------------
resource vnet1 'Microsoft.Network/virtualNetworks@2021-02-01'= {
  name: 'jjvnet1'
  location: location
  properties:{
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }    
    subnets:[
      {
        name: 'snet-jump'
        properties: {
          addressPrefix: '10.1.250.0/24'
        }        
      }
    ]
  }
}

resource vnet2 'Microsoft.Network/virtualNetworks@2021-02-01'= {
  name: 'jjvnet2'
  location: location
  properties:{
    addressSpace: {
      addressPrefixes: [
        '10.2.0.0/16'
      ]
    }    
    subnets:[
      {
        name: 'snet-jump'
        properties: {
          addressPrefix: '10.2.250.0/24'
        }        
      }
    ]
  }
}

resource vnet3 'Microsoft.Network/virtualNetworks@2021-02-01'= {
  name: 'jjvnet3'
  location: location2
  properties:{
    addressSpace: {
      addressPrefixes: [
        '10.3.0.0/16'
      ]
    }    
    subnets:[
      {
        name: 'snet-jump'
        properties: {
          addressPrefix: '10.3.250.0/24'
        }        
      }
    ]
  }
}

resource vnet4 'Microsoft.Network/virtualNetworks@2021-02-01'= {
  name: 'jjvnet4'
  location: location2
  properties:{
    addressSpace: {
      addressPrefixes: [
        '10.4.0.0/16'
      ]
    }    
    subnets:[
      {
        name: 'snet-jump'
        properties: {
          addressPrefix: '10.4.250.0/24'
        }        
      }
    ]
  }
}

// -------------------------
// Virtual machines
// -------------------------

param vmjump1Name string = 'jjvmjump1'

resource vmjump1Pip 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: '${vmjump1Name}-ip'
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    publicIPAddressVersion: 'IPv4'
    idleTimeoutInMinutes: 4
  }
  sku: {
    name: 'Basic'
  }
}

resource vmjump1nic 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: '${vmjump1Name}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: vnet1.properties.subnets[0].id
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: vmjump1Pip.id
          }
        }
      }
    ]
  }
}

resource vmjump1 'Microsoft.Compute/virtualMachines@2021-04-01' = {
  name: vmjump1Name
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmjump1nic.id
        }
      ]
    }
    osProfile: {
      computerName: vmjump1Name
      adminUsername: 'jj'
      adminPassword: password
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

param vmjump2Name string = 'jjvmjump2'

resource vmjump2nic 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: '${vmjump2Name}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: vnet2.properties.subnets[0].id
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

resource vmjump2 'Microsoft.Compute/virtualMachines@2021-04-01' = {
  name: vmjump2Name
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmjump2nic.id
        }
      ]
    }
    osProfile: {
      computerName: vmjump2Name
      adminUsername: 'jj'
      adminPassword: password
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

// -------------------------
// Virtual network manager
// -------------------------

// create manually in portal
