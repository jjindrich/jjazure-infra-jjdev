# JJDev Infrastructure configuration 

## Vnet setup

Hub Vnet **JJDevV2Network** 10.3.0.0/16

- AzureFirewallSubnet 10.3.252.0/24
- GatewaySubnet 10.3.0.0/29
- DmzInfra 10.3.250.0/24
- DmzWeb 10.3.1.0/24

Spoke Vnet **JJDevV2NetworkApp** 10.4.0.0/16

- DmzApp 10.4.1.0/24

Vnet connected via peering JJDevV2Network <-> JJDevV2Network

Vnet JJDevV2Network connected to onprem via **JJDevV2Network** S2S VPN connection to local network 10.1.0.0/16

## Deploy Azure Firewall

It will deploy Azure Firewall and setup UDR on selected subnets.

Firewall will filter traffic between vnets and vpn. Traffic inside vnet is not filtered.

```bash
cd fw
./deploy.sh
```

Check firewall Deny logs

```kusto
search *   
| where Resource == "JJDEVV2FW" and msg_s contains "Deny"
| top 500 by TimeGenerated// return the latest 500 results
| project msg_s 
```

## Deploy Azure Application Gateway

It will deploy Azure Application Gateway. It requires enabled allowed UDRs on Application Gateway subnet. 

Will publish onprem website to internet on HTTP.

```bash
cd appgw
./deploy.sh
```
