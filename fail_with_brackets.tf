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

  name   = "terraform-vm2"
  memory = 1024
  vcpu   = 1








  # Provisioning with cloud-init to create the SSH user

  cloudinit = {
    user_data = <<-EOF
      #cloud-config
      users:
        - name: terraformuser
          ssh-authorized-keys:
            - ${file("~/.ssh/id_rsa.pub")}  # Path to your public SSH key
          sudo: ["ALL=(ALL) NOPASSWD:ALL"]
          shell: /bin/bash
    EOF
  }




}






