$rg = "jjnetwork-rg"
az group create -n $rg -l westeurope

az deployment group create --resource-group $rg --template-file deploy.bicep

$rgvmad = "jjvm-ad-rg"
az group create -n $rgvmad -l westeurope
az deployment group create --resource-group $rgvmad --template-file deploy-vmad.bicep