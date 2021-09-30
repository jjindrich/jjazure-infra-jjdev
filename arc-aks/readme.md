# Deploy Azure AKS with Azure Arc

Docs https://docs.microsoft.com/en-us/Azure/app-service/manage-create-arc-environment

Deploy AKS

```powershell
$aksClusterGroupName="jjarcaks-rg" # Name of resource group for the AKS cluster
$aksName="jjarcaks" # Name of the AKS cluster
$resourceLocation="westeurope"

az group create -g $aksClusterGroupName -l $resourceLocation
az aks create --resource-group $aksClusterGroupName --name $aksName --enable-aad --generate-ssh-keys
$infra_rg=$(az aks show --resource-group $aksClusterGroupName --name $aksName --output tsv --query nodeResourceGroup)
az network public-ip create --resource-group $infra_rg --name MyPublicIP --sku STANDARD
$staticIp=$(az network public-ip show --resource-group $infra_rg --name MyPublicIP --output tsv --query ipAddress)
az aks get-credentials --resource-group $aksClusterGroupName --name $aksName --admin
```

Deploy Arc resources

```powershell
$groupName=$aksClusterGroupName
$clusterName="jjarcaks-cluster" # Name of the connected cluster resource
az connectedk8s connect --resource-group $groupName --name $clusterName
az connectedk8s show --resource-group $groupName --name $clusterName

$logAnalyticsWorkspaceId=$(az monitor log-analytics workspace show `
    --resource-group jjdevmanagement `
    --workspace-name jjdev-analytics `
    --query customerId `
    --output tsv)
$logAnalyticsWorkspaceIdEnc=[Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($logAnalyticsWorkspaceId))# Needed for the next step
$logAnalyticsKey=$(az monitor log-analytics workspace get-shared-keys `
    --resource-group jjdevmanagement `
    --workspace-name jjdev-analytics `
    --query primarySharedKey `
    --output tsv)
$logAnalyticsKeyEnc=[Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($logAnalyticsKey))
```

Deploy App Services extension

```powershell
$extensionName="jjarcaks-ext" # Name of the App Service extension
$namespace="jjarcaks-ns" # Namespace in your cluster to install the extension and provision resources
$kubeEnvironmentName="jjarcaks-env" # Name of the App Service Kubernetes environment resource
az k8s-extension create `
    --resource-group $groupName `
    --name $extensionName `
    --cluster-type connectedClusters `
    --cluster-name $clusterName `
    --extension-type 'Microsoft.Web.Appservice' `
    --release-train stable `
    --auto-upgrade-minor-version true `
    --scope cluster `
    --release-namespace $namespace `
    --configuration-settings "Microsoft.CustomLocation.ServiceAccount=default" `
    --configuration-settings "appsNamespace=${namespace}" `
    --configuration-settings "clusterName=${kubeEnvironmentName}" `
    --configuration-settings "loadBalancerIp=${staticIp}" `
    --configuration-settings "keda.enabled=true" `
    --configuration-settings "buildService.storageClassName=default" `
    --configuration-settings "buildService.storageAccessMode=ReadWriteOnce" `
    --configuration-settings "customConfigMap=${namespace}/kube-environment-config" `
    --configuration-settings "envoy.annotations.service.beta.kubernetes.io/azure-load-balancer-resource-group=${aksClusterGroupName}" `
    --configuration-settings "logProcessor.appLogs.destination=log-analytics" `
    --configuration-protected-settings "logProcessor.appLogs.logAnalyticsConfig.customerId=${logAnalyticsWorkspaceIdEnc}" `
    --configuration-protected-settings "logProcessor.appLogs.logAnalyticsConfig.sharedKey=${logAnalyticsKeyEnc}"
$extensionId=$(az k8s-extension show `
    --cluster-type connectedClusters `
    --cluster-name $clusterName `
    --resource-group $groupName `
    --name $extensionName `
    --query id `
    --output tsv)
az resource wait --ids $extensionId --custom "properties.installState!='Pending'" --api-version "2020-07-01-preview"
```

Deploy Custom location and App Services environment

```powershell
$customLocationName="jjarcaks-loc" # Name of the custom location
$connectedClusterId=$(az connectedk8s show --resource-group $groupName --name $clusterName --query id --output tsv)
az customlocation create `
    --resource-group $groupName `
    --name $customLocationName `
    --host-resource-id $connectedClusterId `
    --namespace $namespace `
    --cluster-extension-ids $extensionId
$customLocationId=$(az customlocation show `
    --resource-group $groupName `
    --name $customLocationName `
    --query id `
    --output tsv)

az appservice kube create `
    --resource-group $groupName `
    --name $kubeEnvironmentName `
    --custom-location $customLocationId `
    --static-ip $staticIp
az appservice kube show --resource-group $groupName --name $kubeEnvironmentName
```

Now you can create Web App running on Linux in custom location.
Url will be like https://jjarcweb.jjarcaks-env-xilykl9o8e5.westeurope.k4apps.io

