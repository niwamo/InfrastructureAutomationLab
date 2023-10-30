# https://github.com/hashicorp/packer-plugin-vmware/tree/main/docs
# https://developer.hashicorp.com/packer/integrations/hashicorp/vmware/latest/components/builder/vmx
# https://pve.proxmox.com/wiki/Install_Proxmox_VE_on_Debian_12_Bookworm

packer {
  required_plugins {
    vmware = {
      version = "~> 1"
      source = "github.com/hashicorp/vmware"
    }
  }
}

variable "vmxPath" {
  type = string
  default = env("VMX_PATH")
}

source "vmware-vmx" "proxmox" {
  source_path = var.vmxPath
  vmx_data = {
    "displayname" = "packer-proxmox"
  }

  disable_vnc = true

  ssh_username = "root"
  ssh_password = "packer"
  ssh_timeout = "30m"
  shutdown_command = "shutdown -P now"
}

build {
  sources = ["sources.vmware-vmx.proxmox"]
  provisioner "shell" {
    expect_disconnect = true
    script = "./scripts/install-pve-1.sh"
  }
  provisioner "shell" {
    start_retry_timeout = "5m"
    expect_disconnect = true
    script = "./scripts/install-pve-2.sh"
    pause_after = "2m"
  }
  provisioner "shell" {
    start_retry_timeout = "5m"
    expect_disconnect = true
    script = "./scripts/install-pve-3.sh"
    pause_after = "1m"
  }
}