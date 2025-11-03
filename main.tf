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




/*

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













































# Define a cloud-init ISO with static IP
data "template_file" "cloudinit_2" {
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

resource "libvirt_cloudinit_disk" "commoninit_2" {
  name           = "terraform-vm-2-cloudinit.iso"
  user_data      = data.template_file.cloudinit_2.rendered
  pool           = "default"
}

resource "libvirt_domain" "example" {

  name   = "terraform-vm2"
  memory = 1024
  vcpu   = 1

  cloudinit = libvirt_cloudinit_disk.commoninit_2.id

  //ami           = "ami-xxxxxxxx" # Replace with your desired AMI ID
  //instance_type = "t2.micro"     # Modify the instance type as needed
  //key_name      = "your-key"     # Replace with your SSH key

  /*

  # User data to configure the instance on boot
  user_data = <<-EOF
              #!/bin/bash
              # Create the user alice and set password
              useradd -m alice
              echo "alice:toto" | chpasswd

              # Disable password-based login for root
              passwd -l root

              # Set the SSH config to allow only alice to SSH in
              echo "AllowUsers alice" >> /etc/ssh/sshd_config
              systemctl restart sshd
            EOF

  */

  /*
  # Security Group settings
  security_groups = ["default"] # You can specify your security group here
  */

  /*
  # Tags for the instance
  tags = {
    Name = "SSH-Only-Alice"
  }
  */
}

/*
output "instance_ip" {
  value = libvirt_domain.example.public_ip
}
*/