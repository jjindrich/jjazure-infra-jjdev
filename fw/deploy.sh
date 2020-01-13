rg='JJDevV2-Infra'

# install firewall and add routes
az group deployment create -g $rg --template-file deploy-fw.json --parameters deploy-fw.params.json

az network vnet subnet update -g $rg -n DmzInfra --vnet-name JJDevV2Network --route-table jjdevv2fw-rt
az network vnet subnet update -g $rg -n DmzWeb --vnet-name JJDevV2Network --route-table jjdevv2fw-rt
az network vnet subnet update -g $rg -n DmzAks --vnet-name JJDevV2Network --route-table jjdevv2fw-rt
az network vnet subnet update -g $rg -n DmzApp --vnet-name JJDevV2NetworkApp --route-table jjdevv2fw-rt
az network vnet subnet update -g $rg -n GatewaySubnet --vnet-name JJDevV2Network --route-table jjdevv2fw-vpn-rt
az network vnet subnet update -g $rg -n AzureApplicationGatewaySubnet --vnet-name JJDevV2Network --route-table jjdevv2fw-appgw-rt
