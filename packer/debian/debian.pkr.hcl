# https://github.com/hashicorp/packer-plugin-vmware/tree/main/docs
# https://developer.hashicorp.com/packer/integrations/hashicorp/vmware/latest/components/builder/iso
# https://cdimage.debian.org/debian-cd/12.2.0/amd64/iso-dvd/
# https://www.debian.org/releases/stable/i386/apbs04.en.html

packer {
  required_plugins {
    vmware = {
      version = "~> 1"
      source = "github.com/hashicorp/vmware"
    }
  }
}

variable "localIP" {
  type = string
  default = env("LOCAL_IP")
}

variable "ide_path" {
  type = string
  default = env("IDE_PATH")
}

variable "vmDNS" {
  type = string
  default = "1.1.1.1"
}

source "vmware-iso" "debian" {
  cpus = 4
  memory = 8192
  network = "nat"

  iso_url = "file:/repo/iso/debian-12.2.0-amd64-DVD-1.iso"
  iso_checksum = "sha256:d969b315de093bc065b4f12ab0dd3f5601b52d67a0c622627c899f1d35834b82"

  vnc_bind_address = "0.0.0.0"
  vnc_port_min = 5900
  vnc_port_max = 5900

  http_content = {
    "/preseed.cfg" = templatefile("${path.root}/preseed.pkrtpl", var)
  }
  
  boot_wait      = "10s"
  boot_command = [
    "<esc><wait>",
    "auto url=http://${var.localIP}:{{ .HTTPPort }}/preseed.cfg",
    "<enter>"
  ]
  
  ssh_username = "root"
  ssh_password = "packer"
  ssh_timeout = "30m"
  shutdown_command = "shutdown -P now"

  vmx_data = {
    "ide0:0.filename" = "${var.ide_path}"
  }
}

build {
  sources = ["sources.vmware-iso.debian"]

  provisioner "shell" {
    script = "./scripts/add-apt-sources.sh"
  }
}