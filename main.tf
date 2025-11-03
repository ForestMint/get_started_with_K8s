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

# Create volumes (VM disks)
resource "libvirt_volume" "ubuntu_disk_1" {
  name           = "ubuntu-jammy.qcow21"
  base_volume_id = libvirt_volume.ubuntu_jammy_img.id
  pool           = "default"
  format         = "qcow2"
}
resource "libvirt_volume" "ubuntu_disk_2" {
  name           = "ubuntu-jammy.qcow22"
  base_volume_id = libvirt_volume.ubuntu_jammy_img.id
  pool           = "default"
  format         = "qcow2"
}

/*
# Create a cloud-init ISO to set hostname, user, and static IP
resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "commoninit.iso"
  user_data      = <<-EOF
    #cloud-config
    hostname: myvm
    manage_etc_hosts: true
    users:
      - name: ubuntu
        sudo: ALL=(ALL) NOPASSWD:ALL
        ssh_authorized_keys:
          - ${file("~/.ssh/id_rsa.pub")}
    write_files:
      - path: /etc/netplan/01-netcfg.yaml
        permissions: '0644'
        content: |
          network:
            version: 2
            ethernets:
              ens3:
                dhcp4: no
                addresses:
                  - 192.168.122.50/24
                gateway4: 192.168.122.1
                nameservers:
                  addresses: [8.8.8.8, 1.1.1.1]
    EOF
  network_config = <<-EOF
    version: 2
    ethernets:
      ens3:
        addresses:
          - 192.168.122.50/24
        gateway4: 192.168.122.1
        nameservers:
          addresses: [8.8.8.8, 1.1.1.1]
    EOF
}
*/

# Create the VMs
resource "libvirt_domain" "ubuntu_jammy_vm_1" {
  name   = "test-vm-1"
  //memory = 512
  memory = 514
  vcpu   = 1

  /*
  network_interface {
    network_name = "default"
  }
  */

  disk {
    volume_id = libvirt_volume.ubuntu_disk_1.id
  }

}

resource "libvirt_domain" "ubuntu_jammy_vm_2" {
  name   = "test-vm-2"
  //memory = 512
  memory = 514
  vcpu   = 1

  /*
  network_interface {
    network_name = "default"
  }
  */

  disk {
    volume_id = libvirt_volume.ubuntu_disk_2.id
  }

}