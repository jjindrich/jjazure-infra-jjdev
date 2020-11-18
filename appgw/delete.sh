rg='JJDevV2-Infra'

az resource delete -g $rg -n jjdevv2appgw --resource-type "Microsoft.Network/applicationGateways"
az resource delete -g $rg -n jjdevv2appgwpolicy --resource-type "Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies"
az resource delete -g $rg -n jjdevv2appgw-ip --resource-type "Microsoft.Network/publicIPAddresses"