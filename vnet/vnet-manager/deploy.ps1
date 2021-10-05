$rg='jjnetworkmanager-rg'

# deploy vnets and manager
az group create -n $rg -l eastus
az deployment group create -g $rg --template-file deploy-vnet-manager.bicep --parameters password=Azure-1234512345