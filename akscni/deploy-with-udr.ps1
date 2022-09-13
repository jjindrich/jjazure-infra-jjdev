# Deploy AKS private cluster with LoadBalancer used for outbound traffic

$rg='JJDevV2-Infra'
$rgmonitor='jjdevmanagement'
$rgaks='jjmicroservices-rg'

# Deploy AKS without public IP
az aks create -n jjaksudr -g $rgaks `
    -x -c 2 -z 1 2 3 `
    --node-vm-size Standard_B2s `
    --assign-identity $(az identity show -g $rgaks --n jjaksprivate --query id -o tsv) `
    --network-plugin azure `
    --vnet-subnet-id $(az network vnet subnet show --vnet-name JJDevV2NetworkApp -g $rg -n DmzAksPrivate --query id -o tsv) `
    --enable-aad --enable-azure-rbac `
    --enable-addons monitoring `
    --workspace-resource-id $(az monitor log-analytics workspace show -g $rgmonitor -n jjdev-analytics --query id -o tsv) `
    --outbound-type userDefinedRouting

# Assign role Azure Kubernetes Service RBAC Cluster Admin
# https://docs.microsoft.com/en-us/azure/aks/manage-azure-rbac

az aks get-credentials --resource-group jjmicroservices-rg --name jjaksudr

# Deploy application using intenal loadbalancer
kubectl apply -f sample-private.yaml
kubectl get service