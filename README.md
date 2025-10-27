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

Inside the machine, run the script managing the first steps

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