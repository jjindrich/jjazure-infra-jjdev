# Script to configure Windows Server RRAS using BGP
# Site configuration: JJDevBR1 for JJWan

# Set variables - vWAN -> VPN GW configuration
$HubAddressSpace = "10.101.250.0/24:100"
$Tunnel1IP = "20.71.83.36"
$PreSharedKey = "abc123"
$BgpPeer = "10.101.250.12"
$BgpAsn = "65515"

# My local site configuration
$RouterPublicIP = "194.213.40.55"
$Network = "10.1.0.0/16"

# Create first interface to tunnel 1
Add-VpnS2SInterface -Name "JJWAN-VPN" -Protocol IKEv2 -Destination $Tunnel1IP -AdminStatus $true -AuthenticationMethod PSKOnly -SharedSecret $PreSharedKey -IPv4Subnet $HubAddressSpace -Persistent -PassThru

# Create BGP identifier
Add-BgpRouter -BgpIdentifier $RouterPublicIP -LocalASN 65100 -PassThru
Add-BgpCustomRoute -Network $Network -PassThru

# Set BGP peers 
Add-BgpPeer -Name "JJWAN-VPN" -LocalIPAddress 10.1.0.10 -PeerIPAddress $BgpPeer -LocalASN 65100 -PeerASN $BgpAsn -PassThru

Connect-VpnS2SInterface -Name "JJWAN-VPN"

# check status to connected (if not, reconnect vpn)
Get-BgpPeer

# list learned routes
route print