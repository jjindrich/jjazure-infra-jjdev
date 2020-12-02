rg='JJDevV2-Infra'

# creates virtual network with NSGs
az deployment group create -g $rg --template-file deploy-vnet.json --parameters deploy-vnet.params.json

# creates virtual in East US
#az deployment group create -g $rg --template-file deploy-vnetus.json --parameters deploy-vnetus.params.json

# deploy vpn and connections
#az deployment group create -g $rg --template-file deploy-vpn.json --parameters deploy-vpn.params.json --parameters vpnGwConnectionKey=
#az deployment group create -g $rg --template-file deploy-vpn.json --parameters deploy-vpn.params-er.json --parameters vpnGwConnectionKey=