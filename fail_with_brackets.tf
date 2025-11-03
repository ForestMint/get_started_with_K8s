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

  # Provisioner to connect via SSH and create the user
  provisioner "remote-exec" {
    inline = [
      "sudo useradd -m example-user"
    ]

    /*
    # Connection details
    connection {
      type        = "ssh"
      user        = "ubuntu"  # Change this to the username for your image
      //private_key = file("~/.ssh/id_rsa")  # Path to your private SSH key
      //host        = self.network_interface[0].addresses[0]  # Using the first network interface's IP
      host = "127.0.0.1"
    }
    */
  }

  name   = "terraform-vm2"
  memory = 1024
  vcpu   = 1

}

