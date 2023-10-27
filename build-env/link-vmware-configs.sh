#!/bin/bash 

mkdir /etc/vmware
configDir='/mnt/c/ProgramData/VMWare/'

device=$(vmrun listHostNetworks | grep nat | awk -F " " '{print $2}')
mkdir -p /etc/vmware/$device/dhcp

ln -s "$configDir"/netmap.conf /etc/vmware/netmap.conf
ln -s "$configDir"/vmnetdhcp.conf /etc/vmware/$device/dhcp/dhcp.conf
ln -s "$configDir"/vmnetdhcp.leases /etc/vmware/$device/dhcp/dhcp.leases
