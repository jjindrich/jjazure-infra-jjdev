$metadata = Invoke-RestMethod -Headers @{"Metadata"="true"} -Method GET -Proxy $Null -Uri "http://169.254.169.254/metadata/instance?api-version=2021-01-01"
$authorizationToken = Invoke-RestMethod -Headers @{"Metadata"="true"} -Method Get -Proxy $Null -Uri "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2021-01-01&resource=https://management.azure.com/"

$subscriptionId = $metadata.compute.subscriptionId
$resourceGroupName = $metadata.compute.resourceGroupName
$vmName = $metadata.compute.name
$accessToken = $authorizationToken.access_token

Invoke-WebRequest -UseBasicParsing -Headers @{ Authorization ="Bearer $accessToken"} -Method POST -Proxy $Null -Uri https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Compute/virtualMachines/$vmName/deallocate?api-version=2021-03-01 -ContentType "application/json"
