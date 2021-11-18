$rg ='JJDevV2-Infra'

# install firewall and associate with subnet
az deployment group create -g $rg --template-file deploy-natgw.bicep

az network vnet subnet update -g $rg -n DmzFunction --vnet-name JJDevV2NetworkApp --nat-gateway jjdevv2natgw
