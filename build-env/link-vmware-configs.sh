#!/bin/bash 

mkdir /etc/vmware
configDir='/mnt/c/ProgramData/VMWare/'

device=$(vmrun listHostNetworks | grep nat | awk -F " " '{print $2}')
mkdir -p /etc/vmware/$device/dhcp

if [ -f "$configDir"/netmap.conf ]; then
ln -s "$configDir"/netmap.conf /etc/vmware/netmap.conf
else 
natNet=$(vmrun listHostNetworks | grep nat | awk -F ' ' '{print $2}')
netNum="${natNet: -1}"
cat << EOF > /etc/vmware/netmap.conf
network$netNum.name = "NAT"
network$netNum.device = "$natNet"
EOF
fi


ln -s "$configDir"/vmnetdhcp.conf /etc/vmware/$device/dhcp/dhcp.conf
ln -s "$configDir"/vmnetdhcp.leases /etc/vmware/$device/dhcp/dhcp.leases

# fools the license check on the official packer plugin 
# we need this even bc of the WSL/host system kludge we're doing
touch /etc/vmware/license-ws-dummy
