$rg ='jjmicroservices-rg'

# find private link service from AKS
$pls = $(az network private-link-service list --query "[].id" -o tsv)

# install frontdoor
az deployment group create -g $rg --template-file deploy-fd.bicep --parameters privateLinkLbId=$pls privateIp=10.4.2.251

# analyze WAF logs
<#
AzureDiagnostics
| where Category == "FrontDoorWebApplicationFirewallLog"
| where action_s == "Block"
| summarize count() by ruleName_s
#>
