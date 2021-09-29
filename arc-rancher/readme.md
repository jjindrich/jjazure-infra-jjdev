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

