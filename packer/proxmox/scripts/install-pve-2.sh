#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# install packages
apt install proxmox-ve postfix open-iscsi chrony ifupdown2 vim -y
# remove old kernel
apt remove linux-image-amd64 'linux-image-6.1*' -y
update-grub
apt remove os-prober -y

systemctl reboot