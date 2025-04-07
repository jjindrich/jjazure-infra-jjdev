# Script to configure Ubuntu NVA to publish custom default route
# https://github.com/tkubica12/azure-networking-lab/blob/master/routeServer/README.md

# must be Ubuntu Server 20.04

sudo -i

apt update
apt install quagga quagga-doc -y
sysctl -w net.ipv4.ip_forward=1

cat > /etc/quagga/zebra.conf << EOF
hostname Router
password zebra
enable password zebra
interface eth0
interface lo
ip forwarding
line vty
EOF

cat > /etc/quagga/vtysh.conf << EOF
!service integrated-vtysh-config
hostname quagga-router
username root nopassword
EOF

cat > /etc/quagga/bgpd.conf << EOF
hostname bgpd
password zebra
enable password zebra
router bgp 65514
network 0.0.0.0/0
neighbor 10.3.253.4 remote-as 65515
neighbor 10.3.253.4 soft-reconfiguration inbound
neighbor 10.3.253.5 remote-as 65515
neighbor 10.3.253.5 soft-reconfiguration inbound
line vty
EOF

chown quagga:quagga /etc/quagga/*.conf
chown quagga:quaggavty /etc/quagga/vtysh.conf
chmod 640 /etc/quagga/*.conf
echo 'zebra=yes' > /etc/quagga/daemons
echo 'bgpd=yes' >> /etc/quagga/daemons
systemctl enable zebra.service
systemctl enable bgpd.service
systemctl start zebra 
systemctl start bgpd 


# check if the BGP is running
sudo vtysh
        show ip bgp cidr-only