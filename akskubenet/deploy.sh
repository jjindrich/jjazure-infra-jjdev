# Deploy AKS cluster with kubenet networking

rg='JJDevV2-Infra'
rgmonitor='jjdevmanagement'
rgaks='jjmicroservices-rg'

# Deploy AKS
az aks create -n jjakskubenet -g $rgaks \
    -x -c 2 -z 1 2 3 --node-resource-group 'jjmicroservices-akskubenet-rg' \
    --node-vm-size Standard_B2s --enable-cluster-autoscaler --min-count 1 --max-count 3 \
    --enable-managed-identity \
    --network-plugin kubenet \
    --vnet-subnet-id $(az network vnet subnet show --vnet-name JJDevV2NetworkApp -g $rg -n DmzAksPrivate --query id -o tsv) \
    --enable-aad --aad-admin-group-object-ids ee2529f7-8f82-450a-9cd5-53968fff8c5d \
    --enable-addons azure-policy,monitoring \
    --workspace-resource-id $(az monitor log-analytics workspace show -g $rgmonitor -n jjdev-analytics --query id -o tsv) 

# Deploy application using intenal loadbalancer
#kubectl apply -f sample-private.yaml
