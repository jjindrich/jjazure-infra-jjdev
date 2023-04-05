targetScope = 'subscription'
param location string = deployment().location
@secure()
param password string

resource rgNetwork 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'jjnetwork-rg'
  location: location
}
module vnet 'deploy-vnet.bicep' = {
  scope: rgNetwork
  name: 'jjazvnet'
  params:{
    location: location
  }
}

resource rgAd 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'jjvm-ad-rg'
  location: location
}
module vmad 'deploy-vmad.bicep' = {
  scope: rgAd
  name: 'jjazvmad'
  params:{
    location: location
    password: password
  }
}

resource rgAadds 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'jjinfra-rg'
  location: location
}
module aadds 'deploy-aadds.bicep' = {
  scope: rgAadds
  name: 'jjaadds'
  params:{
    location: location
  }
}
