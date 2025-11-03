
# Setup and use KVM

## Install KVM

### First, make sure your CPU supports virtualization.
```bash
lscpu | grep Virtualization
```
For Intel CPUs → look for VT-x
For AMD CPUs → look for AMD-V
If the line appears, your hardware supports virtualization.

### Install KVM and related packages
```bash
sudo pacman -Syu
sudo pacman -S qemu-full virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat
```

### Enable and start libvirt
Enable the libvirtd service so that virtual machines can be managed via virt-manager
```bash
sudo systemctl enable libvirtd.service
sudo systemctl start libvirtd.service
```

Check status
```bash
sudo systemctl status libvirtd.service
```

### Add your user to the libvirt group
This allows you to manage VMs without root privileges.
```bash
sudo usermod -aG libvirt $(whoami)
```

### Verify KVM modules are loaded
Check that the kernel modules are active:
```bash
lsmod | grep kvm
```

### Launch Virt-Manager
Run the GUI manager:
```bash
virt-manager
```

## Install Mkisofs

### Update your system

sudo pacman -Syu

### Install cdrtools (contains mkisofs)

sudo pacman -S cdrtools

## Verify installation

mkisofs -version

## Activate terraform network

### Check if the network exists
```bash
sudo virsh net-list --all
```

### If 'terraform-net' exists but is inactive, start it
```bash
sudo virsh net-start terraform-net
```

### (Optional) To make it start automatically on boot
```bash
sudo virsh net-autostart terraform-net
```

## Create VM(s) in KVM with Terraform

```bash
terraform init
terraform plan
yes yes | terraform apply
yes yes | terraform destroy
```

## Check VM(s) with QEMU
```bash
ps -eo pid,cmd | grep qemu-system
```

OR

```bash
./process_qemu_output.sh
```

## Check VM(s) with virsh
```bash
virsh --connect qemu:///system list --all # list all VMs in virsh, the --connect option is because if 'qemu:///system' was used in Terraform file and default for virsh is 'qemu:///session' the virsh list --all will see nothing
export LIBVIRT_DEFAULT_URI=qemu:///system
virsh list --all
```