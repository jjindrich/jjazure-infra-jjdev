rg='JJDevV2-Infra'

# install appgw and nsg
#az deployment group what-if -g $rg --template-file deploy-appgw.json --parameters deploy-appgw.params.json
az deployment group create -g $rg --template-file deploy-appgw-preview.json --parameters deploy-appgw-preview.params.json
