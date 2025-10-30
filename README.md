# ☸️ A simple training to run a K8s cluster (based on [a YT video](https://www.youtube.com/watch?v=_WW16Sp8-Jw))

## Create VMs and set SSH (for kadmin, kmaster (control plane), kworker-1 and kworker-2)

```bash
vagrant up
```

check in VirtualBox machines's network settings that machine is attached to NAT

```bash
vagrant ssh
```

Inside the machine, run the script managing the first steps

```bash
/home/vagrant/first_steps.sh
```

## Connect with SSH (for kadmin, kmaster node, kworker-1 and kworker-2)

from another terminal from your host machine

```bash
ssh alice@<node-ip> # the password will be asked, it is "bubblegum"
```

## Take snapshots (for kmaster node, kworker-1 and kworker-2)

Create a snapshot for all of the 3 VMs at this point of the process.

## Prep for K8s (for kmaster node, kworker-1 and kworker-2)

### check that amount of RAM and CPUs are enough for a K8s cluster (at least 1700 MB RAM and 2 CPUs)

Check the RAM with this command

```bash
cat /proc/meminfo | grep MemTotal:
```

Check the CPU(s) with one the following 3

```bash
nproc
```

```bash
lscpu | grep "CPU(s):"
```

```bash
cat /proc/cpuinfo | grep "cpu cores"
```

### turn off the swap to allow kubelet to work properly

```bash
sudo swapoff -a
sudo vim /etc/fstab # comment the swap line if it appears
swapon --show # check that swap is off
grep swap /etc/fstab
```

### install Docker 

```bash
sudo /home/vagrant/install_docker.sh
```

### setup curl

```bash
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl gpg
```

### Install K8s suite

```bash
sudo /home/vagrant/install_K8s_suite.sh
```

If all goes well, you’ll see version info for each of kubeadm, kubectl and kubelet.

## Start with K8s

### For master node only

```bash
kubeadm version
kubelet --version
dpkg -l | grep kubernetes-cni
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
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --cri-socket /run/containerd/containerd.sock
```

This will write something like below at the end of the output

```bash
Then you can join any number of worker nodes by running the following on each as root:

kubeadm join <my-ip-address>:<my-port> --token <my-token> \
	--discovery-token-ca-cert-hash sha256:<my-sha-256>

```

(6443 being the default port for Kubernetes API)

By running this "kubeadm join" command as root in every worker node, you will make them join the cluster.

Set up your kubectl config
```bash
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

List the running containers from a container runtime that implement the CRI (Container Runtime Interface)
```bash
sudo crictl ps
```

Display in console the certificate that will allow kubectl to monitor the brand new cluster
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

Install kubectl on control plane for debug purpose
```bash
sudo apt install -y kubectl # install kubectl
kubectl version --client # check installation
```

```bash
kubectl config get-contexts
```

Now that we no longer need kubectl on control plane, let's remove it for security reasons
```bash
sudo apt-get remove -y kubectl
```

### Start with kubectl (for kadmin only)

```bash
sudo /home/vagrant/install_kubectl.sh
```

Verify installation

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