$rg = "jjvwan-rg"
az group create -n $rg -l westeurope

# nasazeni pres Biceps
#az deployment group create --what-if --resource-group $rg --template-file deploy.bicep --parameters password=Azure-1234512345
az deployment group create --resource-group $rg --template-file deploy.bicep --parameters password=Azure-1234512345

# nasazeni AKS za FW
<#
$rg='jjvwan-rg'
$rgaks='jjvwan-aks-rg'
az group create -n $rgaks -l westeurope
az aks create -n jjvwanaks -g $rgaks `
    -x -c 2 -z 1 2 3 `
    --enable-managed-identity `
    --network-plugin azure `
    --vnet-subnet-id $(az network vnet subnet show --vnet-name jjvwan-weu-app1 -g $rg -n snet-default --query id -o tsv)    
#>
