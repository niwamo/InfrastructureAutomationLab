export DEBIAN_FRONTEND=noninteractive

# convert to static IP
interface=$(tail -n 1 /etc/network/interfaces | cut -d ' ' -f 2)
ip=$(ip address show dev $interface | grep -Po "(?<=inet\s)(\d{1,3}\.){3}\d{1,3}/\d{2}")
gw=$(ip route | grep default | cut -d ' ' -f 3)
head -n -2 /etc/network/interfaces > /etc/network/interfaces
cat << EOF | tee -a /etc/network/interfaces
auto $interface
iface $interface inet static
    address $ip
    gateway $gw
EOF

# set hostname
hostnamectl set-hostname proxmox-vm

# add /etc/hosts entry
ip=$(echo $ip | cut -d '/' -f 1)
cat << EOF > /etc/hosts
127.0.0.1 localhost.localdomain localhost
$ip proxmox-vm
EOF

# add pve repo
apt update && apt install wget -y
echo "deb [arch=amd64] http://download.proxmox.com/debian/pve bookworm pve-no-subscription" > /etc/apt/sources.list.d/pve-install-repo.list
wget https://enterprise.proxmox.com/debian/proxmox-release-bookworm.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bookworm.gpg 
apt update && apt full-upgrade -y

# install kernel
apt install pve-kernel-6.2 -y

systemctl reboot