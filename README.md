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

## Prep for admininstration (for kadmin)

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
sudo vim ~/.kube/config # copy content of this repo's kubeconfig file
sudo cat ~/.kube/config
kubectl config view
kubectl config get-contexts
```

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
apt list --installed | grep kubernetes-cni
sudo kubeadm init
```

This will write something like below at the end of the output

```bash
Then you can join any number of worker nodes by running the following on each as root:

kubeadm join <my-ip-address>:<my-port> --token <my-token> \
	--discovery-token-ca-cert-hash sha256:<my-sha-256>

```

(6443 being the default port for Kubernetes API)

By running this command as root in every worker node, you will make them join the cluster.

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