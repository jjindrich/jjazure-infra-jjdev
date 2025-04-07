$rg = "jjavs-rg"
az group create -n $rg -l swedencentral
az deployment group create --resource-group $rg --template-file deploy.bicep --no-wait