# Creates VMs in different regions and measures latency between them

az group create -l westeurope -n jjvm-regions-rg

az vm create -n jjazvmubneu -g jjvm-regions-rg --nsg '""' --image Ubuntu2204 --location northeurope --no-wait
az vm create -n jjazvmubweu -g jjvm-regions-rg --nsg '""' --image Ubuntu2204 --location westeurope --no-wait
az vm create -n jjazvmubger -g jjvm-regions-rg --nsg '""' --image Ubuntu2204 --location germanywestcentral --no-wait
az vm create -n jjazvmubpol -g jjvm-regions-rg --nsg '""' --image Ubuntu2204 --location polandcentral --no-wait
az vm create -n jjazvmubswe -g jjvm-regions-rg --nsg '""' --image Ubuntu2204 --location swedencentral --no-wait
az vm create -n jjazvmubfra -g jjvm-regions-rg --nsg '""' --image Ubuntu2204 --location francecentral --no-wait
az vm create -n jjazvmubuks -g jjvm-regions-rg --nsg '""' --image Ubuntu2204 --location uksouth --no-wait

az vm list-ip-addresses -o table --query "[].{VM:virtualMachine.name, PIP:virtualMachine.network.publicIpAddresses[0].ipAddress} | [? contains(VM,'jjazvmub')]"

$vmList = (az vm list-ip-addresses -g jjvm-regions-rg -o tsv --query "[].virtualMachine.network.publicIpAddresses[0].ipAddress")
foreach ($vm in $vmList) {
    "ping $vm"
}

az group delete -n jjvm-regions-rg