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














resource "libvirt_domain" "example" {


  provisioner "local-exec" {
    command = "sudo useradd -m example-user"
  }

  name   = "terraform-vm2"
  memory = 1024
  vcpu   = 1











  /*
  cloudinit = <<-EOF
    #cloud-config

    # Create a user
    users:
      - name: your_username
        gecos: "Your Full Name"
        sudo: ALL=(ALL) NOPASSWD:ALL
        shell: /bin/bash
        groups: sudo
        home: /home/your_username
        lock_passwd: false
        ssh-authorized-keys:
          - ssh-rsa AAAAB3...your_ssh_public_key... user@host

    # Configure SSH
    ssh_pwauth: false  # Disable password authentication (only allow SSH keys)
    disable_root: true # Disable root login over SSH

    # Optional: Install necessary packages (like sudo)
    packages:
      - sudo
  EOF

  */



}






