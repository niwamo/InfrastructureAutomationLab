terraform {
  required_version = ">= 0.14.4"
  required_providers {
    vmworkstation = {
        source = "elsudano/vmworkstation"
        version = "0.2.1"
    }
  }
}

variable "apiHostname" {
  type = string
  default = "desk.local"
}

provider "vmworkstation" {
  user = "tfuser"
  password = "Passw0rd!"
  url = "http://192.168.48.1:8697/api"
  https = false
  debug = false
}

resource "vmworkstation_vm" "test_machine" {
  sourceid = "KEI1JTFTDE05Q0JQU3NGIHSL0NUL36VA"
  denomination = "proxmox"
  description = "A PVE VM"
  path = "C:\\Users\\nwm\\tmp\\tf-test"
  processors = 4
  memory = 8192
}