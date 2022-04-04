terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = ">=2.9.6"
    }
  }
}

resource "random_string" "default" {
  length           = 8
  special          = false
}


provider "proxmox" {
    pm_api_url        = "${var.my_pm_api_url}"
    pm_user           = "${var.my_pm_user}"
    pm_password       = "${var.my_pm_password}"
    pm_tls_insecure   = "true"
    pm_timeout        = 900
    pm_parallel       = 3
}


resource "proxmox_vm_qemu" "linux" {
  count             = "${var.vm_count}"
  agent             = 1
  name              = "${random_string.default.result}"
  desc              = "Created on ${formatdate("YYYYMMDD", timestamp())}"
  target_node       = "pve1"
  clone             = "debian-11.3.0-amd64"
  ipconfig0         = "ip=192.168.50.${(var.ip_address) + (count.index + 1)}/24,gw=192.168.50.254"

  os_type           = "cloud-init"
  cores             = "2"
  sockets           = "1"
  cpu               = "host"
  memory            = 4096
  scsihw            = "virtio-scsi-pci"
  bootdisk          = "scsi0"

  disk {
    size            = "10G"
    type            = "scsi"
    storage         = "storage0"
  }

network {
    model           = "virtio"
    bridge          = "vmbr0"
  }

}
