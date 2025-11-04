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

































resource "libvirt_cloudinit_disk" "admininit" {
  name      = "admininit.iso"
  user_data = data.template_file.user_data_admin.rendered
}

data "template_file" "user_data_admin" {
  template = file("${path.module}/cloud_init_admin.cfg")
}



resource "libvirt_cloudinit_disk" "masterinit" {
  name      = "masterinit.iso"
  user_data = data.template_file.user_data_master.rendered
}

data "template_file" "user_data_master" {
  template = file("${path.module}/cloud_init_master.cfg")
}



resource "libvirt_cloudinit_disk" "workerinit" {
  name      = "workerinit.iso"
  user_data = data.template_file.user_data_worker.rendered
}

data "template_file" "user_data_worker" {
  template = file("${path.module}/cloud_init_worker.cfg")
}





































# Define the OS disk for admin VM
resource "libvirt_volume" "ubuntu_1" {
  name   = "ubuntu.vm_disk_1"
  pool   = "default"
  source = "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
  format = "qcow2"
  
}

# Define the OS disk for master VM
resource "libvirt_volume" "ubuntu_2" {
  name   = "ubuntu.vm_disk_2"
  pool   = "default"
  source = "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
  format = "qcow2"
  
}

# Define the OS disk for worker-1 VM
resource "libvirt_volume" "ubuntu_3" {
  name   = "ubuntu.vm_disk_3"
  pool   = "default"
  source = "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
  format = "qcow2"
  
}

# Define the OS disk for worker-2 VM
resource "libvirt_volume" "ubuntu_4" {
  name   = "ubuntu.vm_disk_4"
  pool   = "default"
  source = "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
  format = "qcow2"

}





























# Create an extra storage (data) disk for admin VM
resource "libvirt_volume" "data_disk_admin" {
  name   = "data-disk.qcow2.admin"
  pool   = "default"
  size   = 128 * 1024 * 1024 * 1024   # 128 GB
  format = "qcow2"
}

# Create an extra storage (data) disk for master VM
resource "libvirt_volume" "data_disk_master" {
  name   = "data-disk.qcow2.master"
  pool   = "default"
  size   = 128 * 1024 * 1024 * 1024   # 128 GB
  format = "qcow2"
}

# Create an extra storage (data) disk for worker-1 VM
resource "libvirt_volume" "data_disk_worker_1" {
  name   = "data-disk.qcow2.worker1"
  pool   = "default"
  size   = 128 * 1024 * 1024 * 1024   # 128 GB
  format = "qcow2"
}

# Create an extra storage (data) disk for worker-2 VM
resource "libvirt_volume" "data_disk_worker_2" {
  name   = "data-disk.qcow2.worker2"
  pool   = "default"
  size   = 128 * 1024 * 1024 * 1024   # 128 GB
  format = "qcow2"
}






















/*
# Create a large base disk for the admin VM
resource "libvirt_volume" "ubuntu_disk_1" {
  name   = "ubuntu-terraform.qcow2.1"
  pool   = "default"                     # Your libvirt storage pool
  format = "qcow2"
  size   = 50 * 1024 * 1024 * 1024       # 50 GB disk
  base_volume_name = "ubuntu-base.qcow2" # optional: base image (cloud image)
}

# Create a large base disk for the master VM
resource "libvirt_volume" "ubuntu_disk_2" {
  name   = "ubuntu-terraform.qcow2.2"
  pool   = "default"                     # Your libvirt storage pool
  format = "qcow2"
  size   = 50 * 1024 * 1024 * 1024       # 50 GB disk
  base_volume_name = "ubuntu-base.qcow2" # optional: base image (cloud image)
}

# Create a large base disk for the worker-1 VM
resource "libvirt_volume" "ubuntu_disk_3" {
  name   = "ubuntu-terraform.qcow2.3"
  pool   = "default"                     # Your libvirt storage pool
  format = "qcow2"
  size   = 50 * 1024 * 1024 * 1024       # 50 GB disk
  base_volume_name = "ubuntu-base.qcow2" # optional: base image (cloud image)
}


# Create a large base disk for the worker-2 VM
resource "libvirt_volume" "ubuntu_disk_4" {
  name   = "ubuntu-terraform.qcow2.4"
  pool   = "default"                     # Your libvirt storage pool
  format = "qcow2"
  size   = 50 * 1024 * 1024 * 1024       # 50 GB disk
  base_volume_name = "ubuntu-base.qcow2" # optional: base image (cloud image)
}
*/
































# Download Ubuntu cloud image and import it into libvirt
resource "libvirt_volume" "ubuntu_base" {
  name   = "ubuntu-base.qcow2"
  pool   = "default"
  source = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  format = "qcow2"
}

# Clone from base
resource "libvirt_volume" "ubuntu_disk_1" {
  name             = "ubuntu-terraform.qcow2.1"
  pool             = "default"
  base_volume_id   = libvirt_volume.ubuntu_base.id
  size             = 50 * 1024 * 1024 * 1024
}

# Clone from base
resource "libvirt_volume" "ubuntu_disk_2" {
  name             = "ubuntu-terraform.qcow2.2"
  pool             = "default"
  base_volume_id   = libvirt_volume.ubuntu_base.id
  size             = 50 * 1024 * 1024 * 1024
}

# Clone from base
resource "libvirt_volume" "ubuntu_disk_3" {
  name             = "ubuntu-terraform.qcow2.3"
  pool             = "default"
  base_volume_id   = libvirt_volume.ubuntu_base.id
  size             = 50 * 1024 * 1024 * 1024
}

# Clone from base
resource "libvirt_volume" "ubuntu_disk_4" {
  name             = "ubuntu-terraform.qcow2.4"
  pool             = "default"
  base_volume_id   = libvirt_volume.ubuntu_base.id
  size             = 50 * 1024 * 1024 * 1024
}





























# Define the admin VM
resource "libvirt_domain" "vm1" {
  name   = "kadmin"
  memory = 1024
  vcpu   = 1

  cloudinit = libvirt_cloudinit_disk.admininit.id

  network_interface {
    network_name   = libvirt_network.default.name
    wait_for_lease = true

  }

  # Attach the disk
  disk {
    volume_id = libvirt_volume.ubuntu_disk_1.id
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

  cloudinit = libvirt_cloudinit_disk.masterinit.id

  network_interface {
    network_name   = libvirt_network.default.name
    wait_for_lease = true

  }

  # Attach the disk
  disk {
    volume_id = libvirt_volume.ubuntu_disk_2.id
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

  cloudinit = libvirt_cloudinit_disk.workerinit.id

  network_interface {
    network_name   = libvirt_network.default.name
    wait_for_lease = true

  }

  # Attach the disk
  disk {
    volume_id = libvirt_volume.ubuntu_disk_3.id
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

  cloudinit = libvirt_cloudinit_disk.workerinit.id

  network_interface {
    network_name   = libvirt_network.default.name
    wait_for_lease = true

  }

  # Attach the disk
  disk {
    volume_id = libvirt_volume.ubuntu_disk_4.id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }
}