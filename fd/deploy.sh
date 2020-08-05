rg='JJDevV2-Infra'

# install frontdoor
az deployment group create -g $rg --template-file deploy-fd.json --parameters deploy-fd.params.json
