param location string = resourceGroup().location
param vmNamePrefix string = 'jjazvm'
@secure()
param password string
param username string = 'jj'

param virtualNetworkResourceGroupName string = 'jjnetwork-rg'
param virtualNetworkName string = 'jjazhubvnet'
param virtualNetworkSubnetName string = 'infra-snet'

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
resource vmadnic 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: '${vmNamePrefix}ad-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnet.id
          }
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.3.250.10'
        }
      }
    ]
  }
}
resource vmad 'Microsoft.Compute/virtualMachines@2021-04-01' = {
  name: '${vmNamePrefix}ad'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1ms'
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmadnic.id
        }
      ]
    }
    osProfile: {
      computerName: '${vmNamePrefix}ad'
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

// resource vmadrun 'Microsoft.Compute/virtualMachines/runCommands@2022-03-01' = {
//   parent: vmad
//   name: 'runad'
//   location: location
//   properties:{
//     source:{
//       script: 'New-Item -itemType Directory -Path C:\\ -Name jj'
//     }
//   }
// }
