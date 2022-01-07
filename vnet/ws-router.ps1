# Script to configure Windows Server RRAS using BGP
# Site configuration: JJDevBR1 for JJDevV2Network

# Set variables - VPN GW configuration
$HubAddressSpace = "10.3.0.0/16:100" # jjdevv2network address space
$Tunnel1IP = "51.124.128.209" # jjdevv2vpngw-ip
$PreSharedKey = "abc123"
$BgpPeer = "10.3.0.30" # jjdevv2vpngw bgp ip
$BgpAsn = "65515" # jjdevv2vpngw bgp asn

# My local site configuration
$RouterPublicIP = "194.213.40.55"
$Network = "10.1.0.0/16"

# Create first interface to tunnel 1
Add-VpnS2SInterface -Name "JJDevV2Network-VPN" -Protocol IKEv2 -Destination $Tunnel1IP -AdminStatus $true -AuthenticationMethod PSKOnly -SharedSecret $PreSharedKey -IPv4Subnet $HubAddressSpace -Persistent -PassThru

# Create BGP identifier
Add-BgpRouter -BgpIdentifier $RouterPublicIP -LocalASN 65100 -PassThru
Add-BgpCustomRoute -Network $Network -PassThru

# Set BGP peers 
Add-BgpPeer -Name "JJDevV2Network-VPN" -LocalIPAddress 10.1.0.10 -PeerIPAddress $BgpPeer -LocalASN 65100 -PeerASN $BgpAsn -PassThru

Connect-VpnS2SInterface -Name "JJDevV2Network-VPN"

# check status to connected (if not, reconnect vpn)
Get-BgpPeer

# list learned routes
route print