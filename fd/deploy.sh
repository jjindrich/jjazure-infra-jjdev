rg='JJDevV2-Infra'

# install frontdoor
az deployment group create -g $rg --template-file deploy-fd.json --parameters deploy-fd.params.json

# install FrontDoor Standard
#az deployment group create -g $rg --template-file deploy-fdv2.json --parameters deploy-fdv2.params.json
