$rg='JJDevV2-Infra'

# remove association from subnets
az network vnet subnet update -g $rg -n DmzFunction --vnet-name JJDevV2NetworkApp --remove natGateway

az resource delete -g $rg -n jjdevv2natgw --resource-type "Microsoft.Network/natGateways"
az resource delete -g $rg -n jjdevv2natgw-ip --resource-type "Microsoft.Network/publicIPAddresses"