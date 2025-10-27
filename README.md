# ☸️ A simple training to run a K8s cluster (based on [a YT video](https://www.youtube.com/watch?v=_WW16Sp8-Jw))

## Create VMs and set SSH

### On master node, worker-1 and worker-2

```bash
vagrant up
```

check in VirtualBox machines's network settings that machine is attached to NAT

```bash
vagrant ssh
```

Inside the machine, run the following steps

```bash
/home/vagrant/first_steps.sh
```

## Connect with SSH

from another terminal from your host machine

```bash
ssh alice@<node-ip> # the password will be asked, it is "bubblegum"
```

## Take snapshots

Create a snapshot for all of the 3 VMs at this point of the process.

## Prep for K8s

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
sudo nano /etc/fstab # comment the swap line
```

### install Docker 

```bash
sudo apt update
sudo apt install docker.io -y
docker --version
systemctl status docker
```

### setup curl

```bash
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl gpg
```

### Install K8s suite

#### Update and install dependencies

```bash
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl gpg
```

#### Add the Kubernetes GPG key

```bash
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
```

#### Add the Kubernetes APT repository

```bash
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

#### Update package lists

```bash
sudo apt update
```

#### Install kubeadm (and optionally kubectl and kubelet)

```bash
sudo apt install -y kubeadm kubelet kubectl
```

#### Prevent automatic updates (optional but recommended)

```bash
sudo apt-mark hold kubeadm kubelet kubectl
```

#### Verify installation

```bash
kubeadm version
kubectl version --client
kubelet --version
```

If all goes well, you’ll see version info for each.