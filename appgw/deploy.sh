rg='JJDevV2-Infra'

# install appgw and nsg
az group deployment create -g $rg --template-file deploy-appgw.json --parameters deploy-appgw.params.json

# associate nsg with subnet
az network vnet subnet update -g $rg -n AzureApplicationGatewaySubnet --vnet-name JJDevV2Network --network-security-group JJDevV2Network-AzureApplicationGatewaySubnet