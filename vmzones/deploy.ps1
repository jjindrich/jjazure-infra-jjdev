$rg='jjzones-rg'

az group create -n $rg -l westeurope
az deployment group create -g $rg --template-file deploy-vmzones.bicep --parameters password=Azure-1234512345