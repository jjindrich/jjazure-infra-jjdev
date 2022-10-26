$rg ='jjnetwork-rg'

# install firewall and add routes
az deployment group create -g $rg --template-file deploy-fw.bicep

az network vnet subnet update -g $rg -n infra-snet --vnet-name jjazhubvnet --route-table jjazhubvnet-infra-rt
az network vnet subnet update -g $rg -n GatewaySubnet --vnet-name jjazhubvnet --route-table jjazhubvnet-vpn-rt
az network vnet subnet update -g $rg -n appgw-snet --vnet-name jjazhubvnet --route-table jjazhubvnet-appgw-rt
az network vnet subnet update -g $rg -n apimngmt-snet --vnet-name jjazhubvnet --route-table jjazhubvnet-apimngmt-rt

az network vnet subnet update -g $rg -n aks-snet --vnet-name jjazappvnet --route-table jjazappvnet-default-rt
az network vnet subnet update -g $rg -n aksprivate-snet --vnet-name jjazappvnet --route-table jjazappvnet-default-rt
az network vnet subnet update -g $rg -n app-snet --vnet-name jjazappvnet --route-table jjazappvnet-default-rt
az network vnet subnet update -g $rg -n avd-snet --vnet-name jjazappvnet --route-table jjazappvnet-default-rt
az network vnet subnet update -g $rg -n function-snet --vnet-name jjazappvnet --route-table jjazappvnet-default-rt
az network vnet subnet update -g $rg -n ase-snet --vnet-name jjazappvnet --route-table jjazappvnet-default-rt
