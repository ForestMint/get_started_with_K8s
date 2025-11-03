
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















# Define a network
resource "libvirt_network" "default" {
  name   = "terraform-net"
  mode   = "nat"
  domain = "terraform.local"

  addresses = ["192.168.100.0/24"]
}


















resource "libvirt_cloudinit_disk" "commoninit" {
  name      = "commoninit.iso"
  user_data = data.template_file.user_data.rendered
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
}




















# Define the VM disk
resource "libvirt_volume" "ubuntu" {
  name   = "ubuntu.qcow2"
  pool   = "default"
  source = "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
  format = "qcow2"
}


















# Define the VM
resource "libvirt_domain" "vm1" {
  name   = "terraform-vm"
  memory = 1024
  vcpu   = 1

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name   = libvirt_network.default.name
    wait_for_lease = true
    /*
    forward_port {
      host_port      = 2222
      guest_port     = 22
      host_ip        = "0.0.0.0"
      protocol       = "tcp"
    }
    */
  }

  disk {
    volume_id = libvirt_volume.ubuntu.id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }
}