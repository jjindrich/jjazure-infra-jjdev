$rg = "jjnetwork-rg"
az group create -n $rg -l westeurope
az deployment group create --resource-group $rg --template-file deploy.bicep

$rgvmad = "jjvm-ad-rg"
az group create -n $rgvmad -l westeurope
az deployment group create --resource-group $rgvmad --template-file deploy-vmad.bicep

$rginfra = "jjinfra-rg"
az group create -n $rginfra -l westeurope
az deployment group create --resource-group $rginfra --template-file deploy-aadds.bicep

$rgvmdb = "jjvm-db-rg"
az group create -n $rgvmdb -l westeurope
az deployment group create --resource-group $rgvmdb --template-file deploy-vmdb.bicep