rg='JJDevV2-Infra'

# creates virtual network wit NSGs
az deployment group create -g $rg --template-file deploy-vnet.json --parameters deploy-vnet.params.json

# deploy vpn and connections
#az deployment group create -g $rg --template-file deploy-vpn.json --parameters deploy-vpn.params.json --parameters vpnGwConnectionKey=
#az deployment group create -g $rg --template-file deploy-vpn.json --parameters deploy-vpn.params-er.json --parameters vpnGwConnectionKey=