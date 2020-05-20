rg='JJDevV2-Infra'

# install api management
az deployment group create -g $rg --template-file deploy-api.json --parameters deploy-api.params.json