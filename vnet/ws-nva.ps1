# Script to configure Windows Server NVA to publish custom default route
# https://learn.microsoft.com/en-us/azure/route-server/peer-route-server-with-virtual-appliance

# NIC IP Forwarding must be enabled in Azure for data plane to work

Install-WindowsFeature RemoteAccess
Install-WindowsFeature RSAT-RemoteAccess-PowerShell
Install-WindowsFeature Routing

Install-RemoteAccess -VpnType RoutingOnly
Get-NetIPInterface | Set-NetIPInterface -Forwarding Enabled

$local_ip = "10.3.250.6"
$ars_ip1 = "10.3.253.4"
$ars_ip2 = "10.3.253.5"

Add-BgpRouter -BgpIdentifier $local_ip -LocalASN "65514" #"65001"
Add-BgpPeer -LocalIPAddress $local_ip -PeerIPAddress $ars_ip1 -PeerASN 65515 -Name "jjroute1"
Add-BgpPeer -LocalIPAddress $local_ip -PeerIPAddress $ars_ip2 -PeerASN 65515 -Name "jjroute2"

Add-BgpCustomRoute -Network "0.0.0.0/0" -Interface "Ethernet"

Get-BgpCustomRoute
Get-BgpPeer
Get-NetRoute
Get-BgpRouteInformation

# TODO:
# nevidim naucene routy pres Get-BgpRouteInformation
# jiny next hop pres redistribute static