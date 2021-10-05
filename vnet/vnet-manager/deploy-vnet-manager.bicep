param location string = 'eastus'

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

// -------------------------
// Virtual network manager
// -------------------------

// create manually in portal
