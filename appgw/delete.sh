rg='JJDevV2-Infra'

az resource delete -g $rg -n jjdevv2appgw --resource-type "Microsoft.Network/applicationGateways"