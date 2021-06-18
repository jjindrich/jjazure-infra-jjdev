$rg = "jjvwan-rg"
az group create -n $rg -l westeurope

# nasazeni pres Biceps
az deployment group create --resource-group $rg --template-file deploy.bicep --parameters password=Azure-1234512345

# virtual wan resource
#az network vwan create -g $rg -n jjvwan

# virtual hubs
#az network vhub create -g $rg --vwan jjvwan -n jjvwan-weu -l westeurope --sku Standard --address-prefix 10.101.250.0/24 --no-wait
#az network vhub create -g $rg --vwan jjvwan -n jjvwan-neu -l northeurope --sku Standard --address-prefix 10.102.250.0/24 --no-wait
#az network vhub create -g $rg --vwan jjvwan -n jjvwan-ger -l germanywestcentral --sku Standard --address-prefix 10.103.250.0/24 --no-wait

# nasazeni jen spoke siti
#$rg = "jjvnet-rg"
#az group create -n $rg -l westeurope
#az deployment group create --resource-group $rg --template-file deploy-spokeonly.bicep --parameters adminPassword=Azure-1234512345

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
