$rg = "jjvwan-rg"

az network vhub delete -g $rg -n jjvwan-weu
az network vhub delete -g $rg -n jjvwan-neu
az network vhub delete -g $rg -n jjvwan-ger
az network vwan delete -g $rg -n jjvwan
az group create -n $rg -l westeurope

