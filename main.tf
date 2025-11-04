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




















# Define the VM disk for admin VM
resource "libvirt_volume" "ubuntu_1" {
  name   = "ubuntu.vm_disk_1"
  pool   = "default"
  source = "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
  format = "qcow2"
}

# Define the VM disk for master VM
resource "libvirt_volume" "ubuntu_2" {
  name   = "ubuntu.vm_disk_2"
  pool   = "default"
  source = "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
  format = "qcow2"
}

# Define the VM disk for worker-1 VM
resource "libvirt_volume" "ubuntu_3" {
  name   = "ubuntu.vm_disk_3"
  pool   = "default"
  source = "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
  format = "qcow2"
}

# Define the VM disk for worker-2 VM
resource "libvirt_volume" "ubuntu_4" {
  name   = "ubuntu.vm_disk_4"
  pool   = "default"
  source = "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
  format = "qcow2"
}






















# Define the admin VM
resource "libvirt_domain" "vm1" {
  name   = "kadmin"
  memory = 1024
  vcpu   = 1

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name   = libvirt_network.default.name
    wait_for_lease = true

  }

  disk {
    volume_id = libvirt_volume.ubuntu_1.id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }
}

# Define the master VM
resource "libvirt_domain" "vm2" {
  name   = "kmaster"
  memory = 10240
  vcpu   = 2

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name   = libvirt_network.default.name
    wait_for_lease = true

  }

  disk {
    volume_id = libvirt_volume.ubuntu_2.id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }
}

# Define the worker-1 VM
resource "libvirt_domain" "vm3" {
  name   = "kworker-1"
  memory = 2048
  vcpu   = 2

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name   = libvirt_network.default.name
    wait_for_lease = true

  }

  disk {
    volume_id = libvirt_volume.ubuntu_3.id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }
}

# Define the worker-2 VM
resource "libvirt_domain" "vm4" {
  name   = "kworker-2"
  memory = 2048
  vcpu   = 2

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name   = libvirt_network.default.name
    wait_for_lease = true

  }

  disk {
    volume_id = libvirt_volume.ubuntu_4.id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }
}