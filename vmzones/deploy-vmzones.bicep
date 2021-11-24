param location string = 'westeurope'
param vmNamePrefix string = 'jjvm'
@secure()
param password string
param username string = 'jj'

param virtualNetworkResourceGroupName string = 'JJDevV2-Infra'
param virtualNetworkName string = 'JJDevV2NetworkApp'
param virtualNetworkSubnetName string = 'DmzApp'

// reference existing network resources
resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: virtualNetworkName
  scope: resourceGroup(virtualNetworkResourceGroupName)
}
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  parent: vnet
  name: virtualNetworkSubnetName
}

// create VM1 in AZ1
resource vm1z1nic 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: '${vmNamePrefix}1z1-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnet.id
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}
resource vm1z1 'Microsoft.Compute/virtualMachines@2021-04-01' = {
  name: '${vmNamePrefix}1z1'
  location: location
  zones: [
    '1'
  ]
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
          id: vm1z1nic.id
        }
      ]
    }
    osProfile: {
      computerName: '${vmNamePrefix}1z1'
      adminUsername: username
      adminPassword: password
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

// create VM2 in AZ1
resource vm2z1nic 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: '${vmNamePrefix}2z1-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnet.id
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}
resource vm2z1 'Microsoft.Compute/virtualMachines@2021-04-01' = {
  name: '${vmNamePrefix}2z1'
  location: location
  zones: [
    '1'
  ]
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
          id: vm2z1nic.id
        }
      ]
    }
    osProfile: {
      computerName: '${vmNamePrefix}2z1'
      adminUsername: username
      adminPassword: password
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

// create VM1 in AZ2
resource vm1z2nic 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: '${vmNamePrefix}1z2-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnet.id
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}
resource vm1z2 'Microsoft.Compute/virtualMachines@2021-04-01' = {
  name: '${vmNamePrefix}1z2'
  location: location
  zones: [
    '2'
  ]
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
          id: vm1z2nic.id
        }
      ]
    }
    osProfile: {
      computerName: '${vmNamePrefix}1z2'
      adminUsername: username
      adminPassword: password
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

// ------------------------------------------------------------------------------------------------
// create placement group
resource ppg 'Microsoft.Compute/proximityPlacementGroups@2021-07-01' = {
  name: '${vmNamePrefix}-ppg'
  location: location
}

// create VM1 in AZ3 with PPG
resource vm1z3nic 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: '${vmNamePrefix}1z3-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnet.id
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}
resource vm1z3 'Microsoft.Compute/virtualMachines@2021-04-01' = {
  name: '${vmNamePrefix}1z3'
  location: location
  zones: [
    '3'
  ]
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
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
          id: vm1z3nic.id
        }
      ]
    }
    osProfile: {
      computerName: '${vmNamePrefix}1z3'
      adminUsername: username
      adminPassword: password
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
    proximityPlacementGroup: {
      id: ppg.id
    }
  }
}

// create VM2 in AZ3 with PPG
resource vm2z3nic 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: '${vmNamePrefix}2z3-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnet.id
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}
resource vm2z3 'Microsoft.Compute/virtualMachines@2021-04-01' = {
  name: '${vmNamePrefix}2z3'
  location: location
  zones: [
    '3'
  ]
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
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
          id: vm2z3nic.id
        }
      ]
    }
    osProfile: {
      computerName: '${vmNamePrefix}2z3'
      adminUsername: username
      adminPassword: password
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
    proximityPlacementGroup: {
      id: ppg.id
    }
  }
}
