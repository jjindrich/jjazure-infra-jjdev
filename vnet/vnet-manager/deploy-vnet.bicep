param location string
param vnetName string
param vnetAddressPrefix string = '10.1'
param vmjumpName string
param username string = 'jj'
@secure()
param password string

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01'= {
  name: vnetName
  location: location
  properties:{
    addressSpace: {
      addressPrefixes: [
        '${vnetAddressPrefix}.0.0/16'
      ]
    }    
    subnets:[
      {
        name: 'snet-jump'
        properties: {
          addressPrefix: '${vnetAddressPrefix}.250.0/24'
        }        
      }
    ]
  }
}

resource vmjumpPip 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: '${vmjumpName}-ip'
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

resource vmjumpnic 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: '${vmjumpName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: vnet.properties.subnets[0].id
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: vmjumpPip.id
          }
        }
      }
    ]
  }
}

resource vmjump 'Microsoft.Compute/virtualMachines@2021-04-01' = {
  name: vmjumpName
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
          id: vmjumpnic.id
        }
      ]
    }
    osProfile: {
      computerName: vmjumpName
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

output vnetId string = vnet.id
