rg='JJDevV2-Infra'

# install api management
az group deployment create -g $rg --template-file deploy-api.json --parameters deploy-api.params.json