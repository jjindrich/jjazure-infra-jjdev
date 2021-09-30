# Deploy Rancher with Azure Arc

## Deploy using jumpstart

Docs https://azurearcjumpstart.io/azure_arc_jumpstart/azure_arc_k8s/rancher_k3s/azure_arm_template/

Clone repository and navigate to azure_arc/azure_arc_k8s_jumpstart/rancher_k3s/azure/arm_template

Update azuredeploy.parameters.json with service principal credentials you created.

```powershell
az group create -n jjrancher-rg -l westeurope

az deployment group create `
--resource-group jjrancher-rg `
--name jjrancher `
--template-uri https://raw.githubusercontent.com/microsoft/azure_arc/main/azure_arc_k8s_jumpstart/rancher_k3s/azure/arm_template/azuredeploy.json `
--parameters azuredeploy.parameters.json
```

## Deploy App Service extension

Docs https://docs.microsoft.com/en-us/Azure/app-service/manage-create-arc-environment

Create prereq resources

```powershell
$rg="jjrancher-rg"
az network public-ip create --resource-group $rg --name jjrancherapps-ip --sku STANDARD
$staticIp=$(az network public-ip show --resource-group $rg --name jjrancherapps-ip --output tsv --query ipAddress)
```

Remove from k3s default ingress Traefik because conflicting 443 port

```ps
helm delete traefik -n kube-system
```

Next go to Azure Portal and add new Application Services extension to Kubernetes - Azure Arc
- instance name jjrancherapps
- new custom location jjrancherloc
- static IP from prereq
- storage class local-path
- And copy script and run it 

### Deployment errors

Custom location deployment failed:

    ERROR: Deployment failed. Correlation ID: 4a68707f-01c2-47eb-9dc1-e7f779304d2f. "Microsoft.ExtendedLocation" resource provider does not have the required permissions to create a namespace on the cluster. Refer to https://aka.ms/ArcK8sCustomLocationsDocsEnableFeature to provide the required permissions to the resource provider.

There is problem with assigned roles to some service principal - creating namespace ???

When deleting Custom location you will get this error:
Deployment failed. Correlation ID: 073bc603-469f-46d3-ac10-164b706eee3a. The operation to Get the Namespace: "jjrancherloc", failed with the following error: "namespaces \"jjrancherloc\" is forbidden: User \"3848bfa9-e47b-4857-8e4f-5d115bbf763c\" cannot get resource \"namespaces\" in API group \"\" in the namespace \"jjrancherloc\""

User 3848bfa9-e47b-4857-8e4f-5d115bbf763c is Custom Locations RP.
