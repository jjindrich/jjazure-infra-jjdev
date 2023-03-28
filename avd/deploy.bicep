param location string = resourceGroup().location
param workspaceName string = 'jjaz-avd'

// Pool 1 - Personal Desktop
resource pool1 'Microsoft.DesktopVirtualization/hostPools@2022-10-14-preview' = {
  name: 'jjavdpool'
  location: location
  properties:{
    hostPoolType: 'Personal'
    personalDesktopAssignmentType: 'Automatic'
    customRdpProperty: 'drivestoredirect:s:*;audiomode:i:0;videoplaybackmode:i:1;redirectclipboard:i:1;redirectprinters:i:1;devicestoredirect:s:*;redirectcomports:i:1;redirectsmartcards:i:1;usbdevicestoredirect:s:*;redirectwebauthn:i:1;use multimon:i:1;singlemoninwindowedmode:i:1;targetisaadjoined:i:1;enablecredsspsupport:i:1;enablerdsaadauth:i:1;'
    loadBalancerType: 'Persistent'
    preferredAppGroupType: 'Desktop'
    startVMOnConnect: true
    vmTemplate: '{"domain":"","galleryImageOffer":"windows-11","galleryImagePublisher":"microsoftwindowsdesktop","galleryImageSKU":"win11-21h2-ent","imageType":"Gallery","customImageId":null,"namePrefix":"jjazvmavd","osDiskType":"StandardSSD_LRS","vmSize":{"id":"Standard_B2ms","cores":2,"ram":8,"rdmaEnabled":false,"supportsMemoryPreservingMaintenance":true},"galleryItemId":"microsoftwindowsdesktop.windows-11win11-21h2-ent","hibernate":false,"diskSizeGB":0,"securityType":"Standard","secureBoot":false,"vTPM":false}'
  }
}
resource groupDagPool1 'Microsoft.DesktopVirtualization/applicationGroups@2022-10-14-preview' = {
  name: 'jjavdpool-DAG'
  location: location
  kind: 'Desktop'
  properties:{
    applicationGroupType: 'Desktop'
    hostPoolArmPath: pool1.id
  }
}

// Pool 2 - Pooled Desktop with apps
resource pool2 'Microsoft.DesktopVirtualization/hostPools@2022-10-14-preview' = {
  name: 'jjavdpoolapp'
  location: location
  properties:{
    hostPoolType: 'Pooled'
    customRdpProperty: 'drivestoredirect:s:*;audiomode:i:0;videoplaybackmode:i:1;redirectclipboard:i:1;redirectprinters:i:1;devicestoredirect:s:*;redirectcomports:i:1;redirectsmartcards:i:1;usbdevicestoredirect:s:*;enablecredsspsupport:i:1;redirectwebauthn:i:1;use multimon:i:1;'
    maxSessionLimit: 5
    loadBalancerType: 'BreadthFirst'
    preferredAppGroupType: 'RailApplications'
    startVMOnConnect: true
    vmTemplate: '{"domain":"jjazure.org","galleryImageOffer":"office-365","galleryImagePublisher":"microsoftwindowsdesktop","galleryImageSKU":"win11-22h2-avd-m365","imageType":"Gallery","customImageId":null,"namePrefix":"jjazvmavd","osDiskType":"StandardSSD_LRS","vmSize":{"id":"Standard_B2ms","cores":2,"ram":8,"rdmaEnabled":false,"supportsMemoryPreservingMaintenance":true},"galleryItemId":"Microsoftwindowsdesktop.office-365win11-22h2-avd-m365","hibernate":false,"diskSizeGB":0,"securityType":"Standard","secureBoot":false,"vTPM":false}'
  }
}
resource groupDagPool2 'Microsoft.DesktopVirtualization/applicationGroups@2022-10-14-preview' = {
  name: 'jjavdpoolapp-DAG'
  location: location
  kind: 'Desktop'
  properties:{
    applicationGroupType: 'Desktop'
    hostPoolArmPath: pool2.id
  }
}
resource groupAppPool2 'Microsoft.DesktopVirtualization/applicationGroups@2022-10-14-preview' = {
  name: 'jjavdpoolapp-Apps'
  location: location
  kind: 'RemoteApp'
  properties:{
    applicationGroupType: 'RemoteApp'
    hostPoolArmPath: pool2.id
  }
}
resource groupAppPol2Edge 'Microsoft.DesktopVirtualization/applicationGroups/applications@2022-10-14-preview' = {
  parent: groupAppPool2
  name: 'Microsoft Edge'
  properties: {
    friendlyName: 'Microsoft Edge'
    filePath: 'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe'
    commandLineSetting: 'DoNotAllow'
    showInPortal: true
    applicationType: 'Inbuilt'
  }
}

// workspace with link to application groups
resource workspace 'Microsoft.DesktopVirtualization/workspaces@2022-10-14-preview' = {
  name: workspaceName
  location: location
  properties: {
    friendlyName: 'JJAzure workspace'
    publicNetworkAccess: 'Enabled'
    applicationGroupReferences: [
      groupDagPool1.id
      groupDagPool2.id
      groupAppPool2.id
    ]
  }
}

// Create session hosts
// sample: https://github.com/pauldotyu/azure-virtual-desktop-bicep
