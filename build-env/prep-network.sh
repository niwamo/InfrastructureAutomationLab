#!/bin/bash 

hostIP=$(ip route | grep -Po "(?<=default\svia\s)(\d{1,3}\.){3}\d{1,3}")

# forward WSL loopback traffic on port 5900 to port 5900 on the Windows host
iptables -t nat -A OUTPUT -p tcp -d 127.0.0.1 --dport 5900 -j DNAT --to-destination $hostIP:5900
iptables -t nat -A POSTROUTING -o eth0 -m addrtype --src-type LOCAL --dst-type UNICAST -j MASQUERADE
sysctl -w net.ipv4.conf.all.route_localnet=1