rg='JJDevV2-Infra'

# delete bastion
az resource delete -g $rg -n jjdevv2bastion --resource-type "Microsoft.Network/bastionHosts"
