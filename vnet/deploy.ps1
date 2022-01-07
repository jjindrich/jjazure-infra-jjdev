$rg = "JJDevV2-Infra"
az group create -n $rg -l westeurope

az deployment group create --resource-group $rg --template-file deploy.bicep
