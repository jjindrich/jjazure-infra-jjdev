rg='JJDevV2-Infra'

# install appgw and nsg
az group deployment create -g $rg --template-file deploy-appgw.json --parameters deploy-appgw.params.json