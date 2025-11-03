terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.7"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

# Download the Ubuntu 22.04 (Jammy) cloud image
resource "libvirt_volume" "ubuntu_jammy_img" {
  name   = "ubuntu-jammy-base"
  pool   = "default"
  source = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
  format = "qcow2"
}

# Create a volume (VM disk)
resource "libvirt_volume" "ubuntu_disk" {
  name           = "ubuntu-jammy.qcow2"
  base_volume_id = libvirt_volume.ubuntu_jammy_img.id
  pool           = "default"
  format         = "qcow2"
}

# Cloud-init user data
resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "ubuntu-jammy-cloudinit.iso"
  user_data      = file("${path.module}/cloud-init.cfg")
  pool           = "default"
}

# Define the VM
resource "libvirt_domain" "ubuntu_jammy" {
  name   = "ubuntu-jammy"
  memory = 2048
  vcpu   = 2

  network_interface {
    network_name = "default"
  }

  disk {
    volume_id = libvirt_volume.ubuntu_disk.id
  }

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  graphics {
    type        = "spice"
    listen_type = "none"
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  boot_device {
    dev = ["hd"]
  }
}

output "vm_ip" {
  value = libvirt_domain.ubuntu_jammy.network_interface[0].addresses[0]
}