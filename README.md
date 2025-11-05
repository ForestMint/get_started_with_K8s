# ☸️ A simple training to run a K8s cluster (based on [a YT video](https://www.youtube.com/watch?v=_WW16Sp8-Jw))

## Prepare the Terraform ecosystem, create the VMs and set SSH (for kadmin, kmaster (control plane), kworker-1 and kworker-2)

### Setup and use KVM

#### Install KVM

##### First, make sure your CPU supports virtualization.
```bash
lscpu | grep Virtualization
```
For Intel CPUs → look for VT-x
For AMD CPUs → look for AMD-V
If the line appears, your hardware supports virtualization.

##### Install KVM and related packages
```bash
sudo pacman -Syu
sudo pacman -S qemu-full virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat
```

##### Enable and start libvirt
Enable the libvirtd service so that virtual machines can be managed via virt-manager
```bash
sudo systemctl enable libvirtd.service
sudo systemctl start libvirtd.service
```

Check status
```bash
sudo systemctl status libvirtd.service
```

##### Add your user to the libvirt group
This allows you to manage VMs without root privileges.
```bash
sudo usermod -aG libvirt $(whoami)
```

##### Verify KVM modules are loaded
Check that the kernel modules are active:
```bash
lsmod | grep kvm
```

##### Launch Virt-Manager
Run the GUI manager:
```bash
virt-manager
```

#### Install Mkisofs

##### Update your system

sudo pacman -Syu

##### Install cdrtools (contains mkisofs)

sudo pacman -S cdrtools

#### Verify installation

mkisofs -version

#### Activate terraform network

##### Check if the network exists
```bash
sudo virsh net-list --all
```

##### If 'terraform-net' exists but is inactive, start it
```bash
sudo virsh net-start terraform-net
```

##### (Optional) To make it start automatically on boot
```bash
sudo virsh net-autostart terraform-net
```

#### Create VM(s) in KVM with Terraform

```bash
terraform init
terraform plan
yes yes | terraform apply
```
This will create the machines, set up SSH to make connecting to it possible and install the right K8s components on each

#### Check VM(s) with QEMU
```bash
ps -eo pid,cmd | grep qemu-system
```

OR

```bash
./process_qemu_output.sh
```

#### Check VM(s) with virsh

Check the VMs run
```bash
virsh --connect qemu:///system list --all # list all VMs in virsh, the --connect option is because if 'qemu:///system' was used in Terraform file and default for virsh is 'qemu:///session' the virsh list --all will see nothing
```

```bash
export LIBVIRT_DEFAULT_URI=qemu:///system #set libvirt default URI those used by terraform for creating infrastructure
```

Check the VMs run
```bash
virsh list --all
```

Check the other items
```bash
virsh net-list --all
virsh vol-list default
```

Check the VM's IP
```bash

```virsh domifaddr kmaster

Ping the VM's IP address
```bash
ping -c 3 <kmaster-IP-address>
```

## Take snapshots (for kmaster node, kworker-1 and kworker-2)

Create a snapshot for all of the 3 VMs at this point of the process.

## Connect with SSH (for kadmin, kmaster, kworker-1 and kworker-2)

from another terminal from your host machine

```bash
ssh alice@<node-ip> # the password will be asked, it is "bubblegum"
```

## Prep for K8s (for kmaster, kworker-1 and kworker-2)

### turn off the swap to allow kubelet to work properly

```bash
sudo swapoff -a
sudo vim /etc/fstab # comment the swap line if it appears
swapon --show # check that swap is off
grep swap /etc/fstab
```

## Start with K8s

### For master node only

Check the success of installation on the 4 required K8s components
```bash
kubeadm version
kubelet --version
dpkg -l | grep kubernetes-cni
kubectl version --client # check installation
```

Install and enable containerd
```bash
sudo apt update
sudo apt install -y containerd
sudo systemctl enable --now containerd
```

Check status of containerd and location of containerd.sock file
```bash
sudo systemctl status containerd
```

```bash
sudo sysctl -w net.ipv4.ip_forward=1
cat /proc/sys/net/ipv4/ip_forward
```

```bash
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --cri-socket unix:///run/containerd/containerd.sock # the --cri-socket option will specity which CRI (Docker Engine, containerd, ...) will be in charge of running the pods required for the control plane to run properly (kube-scheduler-kmaster, ...)
```

This will write something like below at the end of the output

```bash
Then you can join any number of worker nodes by running the following on each as root:

kubeadm join <my-ip-address>:<my-port> --token <my-token> \
	--discovery-token-ca-cert-hash sha256:<my-sha-256>

```

(6443 being the default port for Kubernetes API)

By running this "kubeadm join" command as root in every worker node, you will make them join the cluster.

Destroy the cluster
```bash
yes Y | sudo kubeadm reset # it reverts the 'sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --cri-socket unix:///run/containerd/containerd.sock' that we have run previously
```

Initialize it again
```bash
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --cri-socket unix:///run/containerd/containerd.sock
```

Set up your kubectl config
```bash
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Check the cluster status
```bash
kubectl get nodes
kubectl get pods -n kube-system
```

Apply the Flannel CNI plugin
(this command must be ran quickly after the "kubeadm init" since without any CNI the pods would crash and if kube-apiserver crashes without CNI, the kubelet would restart it on the wrong IP thus putting the kubelet down too which would thus make impossible to apply a CNI and we would be forced to reset the cluster)
```bash
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
```

```bash
kubectl get pods -n kube-system
kubectl get nodes
```

Check in the kubelet configuration where the kubelet checks the manifests, how often it does and set this frequency to 2s
```bash
sudo cat /var/lib/kubelet/config.yaml | grep staticPodPath
sudo cat /var/lib/kubelet/config.yaml | grep fileCheckFrequency

sudo sed -i 's/^\(\s*fileCheckFrequency:\s*\).*/\12s/' /var/lib/kubelet/config.yaml # set fileCheckFrequency to 4s

sudo systemctl daemon-reload
sudo systemctl restart kubelet
sudo systemctl status kubelet # verify you have a "Active: active (running) since [...]" line that displays the elapsed tince since you've run "sudo systemctl restart kubelet"
```

List the running containers from a container runtime that implement the CRI (Container Runtime Interface)
```bash
sudo crictl ps
```

List the current containerd containers
```bash
sudo crictl --runtime-endpoint /run/containerd/containerd.sock ps # depreciated
sudo crictl --runtime-endpoint unix:///run/containerd/containerd.sock ps # not depreciated
```

Show pods that crashed in the past as well as those which are still running
```bash
sudo crictl --runtime-endpoint unix:///run/containerd/containerd.sock ps -a
```

At the minimum, there are 4 essential control plane components (that run as pods in most setups like kubeadm used here) that must be running for the cluster to function properly :

kube-apiserver 				handles all API requests
etcd   						stores the cluster state
kube-controller-manager  	ensures desired state is maintained
kube-scheduler   			assigns pods to nodes

Without any one of these, the control plane is considered non-functional.

When we run "kubeadm init", the components will be started as static pods. Those pods manifest YAML files are placed in the folder /etc/kubernetes/manifests.
The kubelet agent on the node continuously watches this repository and as soos as it detects that a node is not running, it will try to recreate it automatically.










If all the 4 pods are running without crashing, go to next step.
Else, run

```bash
sudo journalctl -u kubelet -f
```
You might see some CrashLoopBackOff in the logs

and inspect the manifest of the naughty pod with 
```bash
sudo cat /etc/kubernetes/manifests/<naughty-pod>.yaml
```
possibly looking for misconfigurations (e.g., wrong volume mounts, bad image, bad args), file paths that don’t exist on the node or environment variables that are missing



Make sure the right of the manifests (files and folder) are good for the kubelet (that runs as root)
```bash
sudo chown root:root /etc/kubernetes/manifests/*.yaml
sudo chmod 644 /etc/kubernetes/manifests/*.yaml
sudo chmod 755 /etc/kubernetes/manifests
sudo chown root:root /etc/kubernetes/manifests
sudo systemctl restart kubelet
sudo systemctl status kubelet
sudo journalctl -u kubelet -f
```




make sure ping the API server works
```bash
curl -k https://<kubernetes-apiserver-ip-address>:<kubernetes-apiserver-port>/healthz
curl -k https://<kubernetes-apiserver-ip-address>:<kubernetes-apiserver-port>/livez?verbose
```































Display in console the certificate that will allow kubectl on admin machine to monitor the brand new cluster
```bash
cat /etc/kubernetes/pki/ca.crt
```

Extract the certificate and key from /etc/kubernetes/admin.conf
```bash
sudo grep 'client-certificate-data' /etc/kubernetes/admin.conf | awk '{print $2}' | base64 -d > client.crt
sudo grep 'client-key-data' /etc/kubernetes/admin.conf | awk '{print $2}' | base64 -d > client.key
```

Display in console the client certificate that will allow kubectl to monitor the brand new cluster
```bash
cat client.crt
```

Display in console the client key that will allow kubectl to monitor the brand new cluster
```bash
cat client.key
```

```bash
kubectl config get-contexts
```

Now that we no longer need kubectl on control plane, let's remove it for security reasons
```bash
sudo apt-get remove -y kubectl
```

### Start with kubectl (for kadmin only)

Verify installation of Kubectl
```bash
kubectl version --client
```

```bash
cd
mkdir .kube
cd .kube
touch config
sudo vim ~/.kube/config # paste content of this repo's kubeconfig file
sudo cat ~/.kube/config

sudo touch ~/.kube/ca.crt
sudo vim ~/.kube/ca.crt # paste content of certificate displayed in the control plane (/etc/kubernetes/pki/ca.crt)
sudo cat ~/.kube/ca.crt

sudo touch ~/.kube/client.crt
sudo vim ~/.kube/client.crt # paste content of certificate displayed in the control plane (client.crt)
sudo cat ~/.kube/client.crt

sudo touch ~/.kube/client.key
sudo vim ~/.kube/client.key # paste content of key displayed in the control plane (client.key)
sudo cat ~/.kube/client.key

kubectl config view --raw
kubectl config view
kubectl config get-contexts # shows that there is no active context (blank in col 1, row 1)
kubectl config use-context sandbox-context #activates the context
kubectl config get-contexts

kubectl cluster-info
```

### For every worker node only

Check the success of installation on the 3 required K8s components
```bash
kubeadm version
kubelet --version
dpkg -l | grep kubernetes-cni
```

```bash
sudo su -
```

Then in root console :

```bash
kubeadm join <my-ip-address>:<my-port> --token <my-token> \
	--discovery-token-ca-cert-hash sha256:<my-sha-256>
```

If it gets stuck at pre-fligh checks :

```bash
ping <my-ip-address>

sudo apt install nmap

nmap -p <my-port> <my-ip-address>
```

## Destroy the VM(s) hosting the cluster
```bash
yes yes | terraform destroy
```