param location string = resourceGroup().location
param vmNamePrefix string = 'jjazvm'
@secure()
param password string
param username string = 'jj'

param virtualNetworkResourceGroupName string = 'jjnetwork-rg'
param virtualNetworkName string = 'jjazappvnet'
param virtualNetworkSubnetName string = 'app-snet'

// reference existing network resources
resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: virtualNetworkName
  scope: resourceGroup(virtualNetworkResourceGroupName)
}
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  parent: vnet
  name: virtualNetworkSubnetName
}

// create VMs for DB 
var vmCountDb = 1
var vmNamePrefixDb = '${vmNamePrefix}db'
resource vmdbnic 'Microsoft.Network/networkInterfaces@2022-05-01' = [for i in range(1, vmCountDb): {
  name: '${vmNamePrefixDb}${i}-nic'
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
}]
resource vmdb 'Microsoft.Compute/virtualMachines@2022-08-01' =  [for i in range(1, vmCountDb): {
  name: '${vmNamePrefixDb}${i}'
  location: location
  zones: [ '${i}' ]
  properties: {    
    hardwareProfile: {
      vmSize: 'Standard_D2ds_v5'
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
      dataDisks: [        
        {
          createOption: 'Empty'
          lun: 0          
          diskSizeGB: 128
          managedDisk:{
            storageAccountType: 'PremiumV2_LRS'
          }
        }
      ]
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
          id: resourceId('Microsoft.Network/networkInterfaces', '${vmNamePrefixDb}${i}-nic')
        }
      ]
    }
    osProfile: {
      computerName: '${vmNamePrefixDb}${i}'
      adminUsername: username
      adminPassword: password
    }    
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }  
  }
  dependsOn: [
    vmdbnic
  ]  
}]
