# install packages
DEBIAN_FRONTEND=noninteractive apt install proxmox-ve postfix open-iscsi chrony -y
# remove old kernel
apt remove linux-image-amd64 'linux-image-6.1*' -y
update-grub
apt remove os-prober -y
systemctl reboot