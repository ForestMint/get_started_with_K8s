
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

## Create VM(s) in KVM with Terraform

```bash
terraform init
terraform plan
yes yes | terraform apply
yes yes | terraform destroy
```