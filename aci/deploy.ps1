$rg='jjaci-rg'
$rgNetwork='JJDevV2-Infra'

az group create -n $rg -l westeurope

$vnet=$(az network vnet subnet show --vnet-name JJDevV2NetworkApp -g $rgNetwork -n DmzAci --query id -o tsv )

$val = 1
while($val -ne 60)
{
    az container create -g $rg -n jjaci$val `
    --image mcr.microsoft.com/azuredocs/aci-helloworld `
    --subnet $vnet --no-wait

    $val++
    Write-Host $val
}

// limits: https://docs.microsoft.com/en-us/azure/container-instances/container-instances-quotas#service-quotas-and-limits