$rg='JJDevV2-Infra'

# remove routes, dns settings and delete firewall
az network vnet subnet update -g $rg -n infra-snet --vnet-name jjazhubvnet --remove routeTable 
az network vnet subnet update -g $rg -n GatewaySubnet --vnet-name jjazhubvnet --remove routeTable
az network vnet subnet update -g $rg -n appgw-snet --vnet-name jjazhubvnet --remove routeTable
az network vnet subnet update -g $rg -n apimngmt-snet --vnet-name jjazhubvnet --remove routeTable

az network vnet subnet update -g $rg -n aks-snet --vnet-name jjazappvnet --remove routeTable
az network vnet subnet update -g $rg -n aksprivate-snet --vnet-name jjazappvnet --remove routeTable
az network vnet subnet update -g $rg -n app-snet --vnet-name jjazappvnet --remove routeTable
az network vnet subnet update -g $rg -n avd-snet --vnet-name jjazappvnet --remove routeTable
az network vnet subnet update -g $rg -n function-snet --vnet-name jjazappvnet --remove routeTable
az network vnet subnet update -g $rg -n ase-snet --vnet-name jjazappvnet --remove routeTable

az network vnet update -g $rg -n jjazappvnet --dns-servers ''

az resource delete -g $rg -n jjazfw --resource-type "Microsoft.Network/azureFirewalls"
az resource delete -g $rg -n jjazfw-policy --resource-type "Microsoft.Network/firewallPolicies"
az resource delete -g $rg -n jjazfw-ip --resource-type "Microsoft.Network/publicIPAddresses"