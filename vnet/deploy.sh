rg='JJDevV2-Infra'

# creates virtual network wit NSGs
az group deployment create -g $rg --template-file deploy-vnet.json --parameters deploy-vnet.params.json