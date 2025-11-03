terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.6"
    }
  }
}


provider "libvirt" {
  uri = "qemu:///system"
}


# Use an existing image or small cloud image
resource "libvirt_volume" "ubuntu_jammy_img" {
  name   = "test-vm.qcow2"
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


resource "libvirt_domain" "test_vm" {
  name   = "test-vm"
  //memory = 512
  memory = 514
  vcpu   = 1
  disk {
    volume_id = libvirt_volume.ubuntu_disk.id
  }
}