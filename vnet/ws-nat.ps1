# Script to create NAT interface on HyperV machine

New-VMSwitch -SwitchName "NATSwitch" -SwitchType Internal
New-NetIPAddress -IPAddress 192.168.0.1 -PrefixLength 24 -InterfaceAlias "vEthernet (NATSwitch)"
New-NetNAT -Name "NATNetwork" -InternalIPInterfaceAddressPrefix 192.168.0.0/24
# it will not assing IP address automatically

# Create DHCP server
# - scope 192.168.0.2 - 192.168.0.100
