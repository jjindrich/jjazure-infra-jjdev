$rg = "jjvwan-rg"
az group create -n $rg -l westeurope

# virtual wan resource
az network vwan create -g $rg -n jjvwan

# virtual hubs
az network vhub create -g $rg --vwan jjvwan -n jjvwan-weu -l westeurope --sku Standard --address-prefix 10.101.250.0/24 --no-wait
az network vhub create -g $rg --vwan jjvwan -n jjvwan-neu -l northeurope --sku Standard --address-prefix 10.102.250.0/24 --no-wait
az network vhub create -g $rg --vwan jjvwan -n jjvwan-ger -l germanywestcentral --sku Standard --address-prefix 10.103.250.0/24 --no-wait
