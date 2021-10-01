# Deploy Rancher K3s with Azure Arc and Azure Services

Prepare App registration for adding K3s in Azure Arc - jjrancherk3s

## Deploy K3s using jumpstart

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

Remove from k3s default ingress Traefik because conflicting 443 port

```ps
helm delete traefik -n kube-system
```

!!! **There is a bug** - hardcoded iod for custom location. Check issue https://github.com/microsoft/azure_arc/issues/785

## Deploy K3s using script

Create VM

```powershell
$rg = "jjrancher-rg"
$myip=$(curl -4 ifconfig.io)
az group create -n $rg -l westeurope

az network nsg create -g $rg -n jjrancher-nsg
az network nsg rule create -g $rg `
    --nsg-name jjrancher-nsg `
    -n ssh `
    --priority 150 `
    --source-address-prefixes $myip/32 `
    --destination-port-ranges 22 `
    --protocol Tcp `
    --description ssh
az vm create -n jjrancher -g $rg --image UbuntuLTS `
    --size Standard_B2ms --authentication-type password --admin-username jj `
    --nsg jjrancher-nsg --public-ip-address jjrancher-ip --storage-sku StandardSSD_LRS 
```

Install K3s and connect to Azure Arc

```sh
# Install K3s without Traefik
curl -sfL https://get.k3s.io | sh -s - --disable=traefik

# Install Azure CLI and extensions
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az extension add --upgrade --yes --name connectedk8s
az extension add --upgrade --yes --name k8s-extension
az extension add --upgrade --yes --name customlocation
az extension remove --name appservice-kube
az extension add --yes --source "https://aka.ms/appsvc/appservice_kube-latest-py2.py3-none-any.whl"

#az login --tenant jjdev.onmicrosoft.com --service-principal -u 30b63f8d-eb8d-4618-9bd6-1e0b548bb8ca -p <SECRET>
az login
mkdir .kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown jj:jj ~/.kube
sudo chown jj:jj ~/.kube/config
export KUBECONFIG=~/.kube/config

az connectedk8s connect -g jjrancher-rg -n jjrancher
az connectedk8s show -g jjrancher-rg -n jjrancher --query provisioningState   # Should show Succeeded
```

!!! *There is a bug* - when using service principal, deployment of custom location will fail

## Deploy App Service extension

Docs https://docs.microsoft.com/en-us/Azure/app-service/manage-create-arc-environment

Custom location works docs https://docs.microsoft.com/en-us/azure/azure-arc/kubernetes/conceptual-custom-locations

Next go to Azure Portal and add new Application Services extension to Kubernetes - Azure Arc
- instance name - jjrancherapps
- new custom location - jjrancherloc
- static IP - VM public ip
- storage class - local-path
- And copy script and run it 

Next add NSG rule to allow communication for web

```powershell
$rg = "jjrancher-rg"
az network nsg rule create -g $rg `
    --nsg-name jjrancher-nsg `
    -n web `
    --priority 160 `
    --source-address-prefixes * `
    --destination-port-ranges 443 `
    --protocol Tcp
```