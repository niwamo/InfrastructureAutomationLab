export DEBIAN_FRONTEND=noninteractive

# install packages
apt install proxmox-ve postfix open-iscsi chrony ifupdown2 vim -y
# remove old kernel
apt remove linux-image-amd64 'linux-image-6.1*' -y
update-grub
apt remove os-prober -y

# update networking
interface=$(grep -Po "(?<=^auto\s)\w+" /etc/network/interfaces | grep -v lo)
ip=$(grep -Po "(?<=\saddress\s)(\d{1,3}\.){3}\d{1,3}" /etc/network/interfaces)
gw=$(grep -Po "(?<=\sgateway\s)(\d{1,3}\.){3}\d{1,3}" /etc/network/interfaces)
brctl addbr vmbr0
head -n -4 /etc/network/interfaces > /etc/network/interfaces
cat << EOF > /etc/network/interfaces
auto lo
iface lo inet loopback

iface $interface inet manual

auto vmbr0
iface vmbr0 inet static
    address $ip/24
    gateway $gw
    bridge-ports $interface
    bridge-stp off
    bridge-fd 0
    post-up iptables -t nat -A PREROUTING -p tcp -d $ip --dport 443 -j REDIRECT --to-ports 8006

EOF

systemctl reboot