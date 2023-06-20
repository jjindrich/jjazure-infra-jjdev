$rg ='jjmicroservices-rg'

# install frontdoor
az deployment group create -g $rg --template-file deploy-fd.bicep

# analyze WAF logs
<#
AzureDiagnostics
| where Category == "FrontDoorWebApplicationFirewallLog"
| where action_s == "Block"
| summarize count() by ruleName_s
#>
