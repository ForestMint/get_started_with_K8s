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

/*
# Define a network
resource "libvirt_network" "default" {
  name   = "terraform-net"
  mode   = "nat"
  domain = "terraform.local"

  addresses = ["192.168.100.0/24"]
}

# Define a cloud-init ISO with static IP
data "template_file" "cloudinit" {
  template = <<EOF
#cloud-config
hostname: terraform-vm
manage_etc_hosts: true
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: false
      addresses: [192.168.100.50/24]
      gateway4: 192.168.100.1
      nameservers:
        addresses: [8.8.8.8,8.8.4.4]
EOF
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "terraform-vm-cloudinit.iso"
  user_data      = data.template_file.cloudinit.rendered
  pool           = "default"
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


# Define the VM disk
resource "libvirt_volume" "ubuntu" {
  name   = "ubuntu.qcow2"
  pool   = "default"
  source = "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
  format = "qcow2"
}

*/





















/*
resource "qemu_image" "ubuntu_base" {
  source_image = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  output_image = "${path.module}/ubuntu-base.qcow2"
}
*/

# Define the VM disk
resource "libvirt_volume" "ubuntu" {
  name   = "ubuntu.qcow2"
  pool   = "default"
  source = "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
  format = "qcow2"
}

# Define a cloud-init ISO with static IP
data "template_file" "cloudinit" {
  template = <<EOF
#cloud-config
hostname: terraform-vm
manage_etc_hosts: true
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: false
      addresses: [192.168.100.50/24]
      gateway4: 192.168.100.1
      nameservers:
        addresses: [8.8.8.8,8.8.4.4]
EOF
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "terraform-vm-cloudinit.iso"
  user_data      = data.template_file.cloudinit.rendered
  pool           = "default"
}

resource "libvirt_domain" "vm1" {
  name        = "alice-vm"
  memory      = 2048
  //cores       = 2
  vcpu   = 1
  disk {
    volume_id = libvirt_volume.ubuntu.id
  }

  /*
  # Cloud-init config
  cloud_init {
    user_data = file("${path.module}/cloud_init.cfg")
  }
  */

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    //model   = "virtio"
    //network = "user"
    # Expose SSH on host port 2222
    /*
    forward_port {
      host_port      = 2222
      guest_port     = 22
      host_ip        = "0.0.0.0"
      protocol       = "tcp"
    }
    */
  }

  # VM lifecycle
  lifecycle {
    create_before_destroy = true
  }
}

output "ssh_connection" {
  value = "ssh alice@localhost -p 2222 -i id_rsa"
}
