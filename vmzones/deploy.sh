rg='jjdevv2vmwebzones-rg'

# deploy VMs in different zones - 2 VMs in AZ1, 1 VM in AZ2, 1 VM in AZ3
az group create -n $rg -l westeurope
az deployment group create -g $rg --mode complete --template-file deploy-vmzones.json --parameters deploy-vmzones.params.json --parameters adminPassword=Azure-1234512345