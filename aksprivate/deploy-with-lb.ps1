# Deploy AKS private cluster with LoadBalancer used for outbound traffic

$rg='JJDevV2-Infra'
$rgmonitor='jjdevmanagement'
$rgaks='jjmicroservices-rg'

# Hub resources - DNS zone
az network private-dns zone create -g $rg -n privatelink.westeurope.azmk8s.io
az network private-dns link vnet create -n hub -g $rg -z privatelink.westeurope.azmk8s.io -e false -v $(az network vnet show -n JJDevV2Network -g JJDevV2-Infra --query id -o tsv)

# User identity for AKS
az identity create --name jjaksprivate --resource-group $rgaks

# Deploy AKS private
az aks create -n jjaksprivate -g $rgaks `
    -x -c 2 -z 1 2 3 `
    --node-osdisk-type Standard_SSD --node-vm-size Standard_B2s `
    --assign-identity $(az identity show -g $rgaks --n jjaksprivate --query id -o tsv) `
    --network-plugin azure `
    --vnet-subnet-id $(az network vnet subnet show --vnet-name JJDevV2NetworkApp -g $rg -n DmzAksPrivate --query id -o tsv) `
    --enable-private-cluster `
    --private-dns-zone $(az network private-dns zone show -g $rg -n privatelink.westeurope.azmk8s.io --query id -o tsv) `
    --enable-aad --enable-azure-rbac `
    --enable-addons monitoring `
    --workspace-resource-id $(az monitor log-analytics workspace show -g $rgmonitor -n jjdev-analytics --query id -o tsv) `
    --outbound-type LoadBalancer

# Deploy application using intenal loadbalancer
kubectl apply -f sample-private.yaml

# Deploy application published by public load balancer
kubectl apply -f sample-publiclb.yaml