$rg='jjnetworkmanager-rg'

# deploy vnets and manager
az group create -n $rg -l westcentralus
az deployment group create -g $rg --template-file deploy.bicep --parameters password=Azure-1234512345

$configId = (az network manager connect-config list --network-manager-name "jjaznetworkmanager" --resource-group "jjnetworkmanager-rg" --query "[].{id:id}" -o tsv)
az network manager post-commit --network-manager-name "jjaznetworkmanager" --resource-group "jjnetworkmanager-rg" --commit-type "Connectivity" --configuration-ids $configId --target-locations "westcentralus"