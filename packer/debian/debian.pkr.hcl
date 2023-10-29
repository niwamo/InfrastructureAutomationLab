# Plugin Repo
# https://github.com/hashicorp/packer-plugin-vmware/tree/main/docs

# Plugin Docs
# https://developer.hashicorp.com/packer/integrations/hashicorp/vmware/latest/components/builder/iso

# Download link for iso
# https://cdimage.debian.org/debian-cd/12.2.0/amd64/iso-dvd/

# Some Preseed info
# https://www.debian.org/releases/stable/i386/apbs04.en.html

# The example preseed with all settings and explanations
# https://www.debian.org/releases/stable/example-preseed.txt

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

variable "idePath" {
  type = string
  default = env("IDE_PATH")
}

variable "isoUrl" {
  type = string
  default = env("ISO_URL")
}

variable "isoChecksum" {
  type = string
  default = env("ISO_CHECKSUM")
}

variable "vmDNS" {
  type = string
  default = "1.1.1.1"
}

source "vmware-iso" "debian" {
  cpus = 4
  memory = 8192
  network = "nat"

  iso_url = var.isoUrl
  iso_checksum = var.isoChecksum

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
    "ide0:0.filename" = "${var.idePath}"
  }
}

build {
  sources = ["sources.vmware-iso.debian"]

  provisioner "shell" {
    script = "./scripts/add-apt-sources.sh"
  }
}