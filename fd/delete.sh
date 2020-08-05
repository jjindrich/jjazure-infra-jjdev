rg='JJDevV2-Infra'

az resource delete -g $rg -n jjdevv2fd --resource-type "Microsoft.Network/frontdoors"
az resource delete -g $rg -n jjdevv2fdpolicy --resource-type "Microsoft.Network/frontdoorwebapplicationfirewallpolicies"
