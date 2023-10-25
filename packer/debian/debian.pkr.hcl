# https://github.com/hashicorp/packer-plugin-vmware/tree/main/docs
# https://developer.hashicorp.com/packer/integrations/hashicorp/vmware/latest/components/builder/iso

packer {
  required_plugins {
    vmware = {
      version = "~> 1"
      source = "github.com/hashicorp/vmware"
    }
  }
}

source "vmware-iso" "debian" {
  iso_url = "http://old-releases.ubuntu.com/releases/precise/ubuntu-12.04.2-server-amd64.iso"
  iso_checksum = "md5:af5f788aee1b32c4b2634734309cc9e9"
  ssh_username = "packer"
  ssh_password = "packer"
  shutdown_command = "shutdown -P now"
}

build {
  sources = ["sources.vmware-iso.debian"]
}
