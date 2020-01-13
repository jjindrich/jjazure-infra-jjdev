rg='JJDevV2-Infra'

# remove routes and delete firewall
az network vnet subnet update -g $rg -n DmzInfra --vnet-name JJDevV2Network --remove routeTable 
az network vnet subnet update -g $rg -n DmzWeb --vnet-name JJDevV2Network --remove routeTable
az network vnet subnet update -g $rg -n DmzAks --vnet-name JJDevV2Network --remove routeTable
az network vnet subnet update -g $rg -n DmzApp --vnet-name JJDevV2NetworkApp --remove routeTable
az network vnet subnet update -g $rg -n GatewaySubnet --vnet-name JJDevV2Network --remove routeTable
az network vnet subnet update -g $rg -n AzureApplicationGatewaySubnet --vnet-name JJDevV2Network --remove routeTable

az resource delete -g $rg -n jjdevv2fw --resource-type "Microsoft.Network/azureFirewalls"