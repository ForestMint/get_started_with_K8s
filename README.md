# ☸️ A simple training to run a K8s cluster (based on [a YT video](https://www.youtube.com/watch?v=_WW16Sp8-Jw))

## 📋 Prerequisites (for Linux Ubuntu 24.04 system)

- deactivate the 'Secure Boot' option for your machine in the BIOS

- install VirtualBox

```sh
$ sudo apt-get install virtualbox
```

- install vagrant

```sh
$ wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
```

```sh
$ echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
```

```sh
$ sudo apt update && sudo apt install vagrant
```

```sh
$ vagrant --version
```

## ☸️ Deploy K8s

### In each folder (./master, ./worker-1, ./worker-2), run the following commands :

🖥 Power the machines on

```sh
$ vagrant up
```

🔐 Setup SSH

```sh
$ vagrant ssh
$ sudo apt update
$ sudo apt install ssh
$ sudo ufw allow 22
$ sudo su
$ nano /etc/ssh/sshd_config
```
Add :
Port 1234
PermitRootLogin no
AllowUsers jim
```ssh
$ AllowUsers jim@1.2.3.4
$ sudo service ssh reload
```

Turn the [swap](https://en.wikipedia.org/wiki/Memory_paging#Linux) off to allow the kubelet to work properly

```sh
$ sudo swapoff -a
```

Install nano (if not installed yet)

```sh
$ sudo apt install nano
```

Comment the swap part in /etc/fstab with

```sh
$ sudo nano /etc/fstab
```

Install Docker

```sh
$ sudo apt install docker.io -y
```

Install curl (if not installed yet)

```sh
$ sudo apt install apt-transport-https curl -y
```

Add repositories

```sh
$ curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
$ sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
```

☸️ Install Kubeadm, Kubelet, Kubectl and Kubernetes

```sh
$ sudo apt install kubeadm kubelet kubetcl kubernetes-cni -y
```

OR

```sh
$ sudo snap install kubeadm --classic
$ sudo snap install kubelet --classic
$ sudo snap install kubectl --classic

#$ sudo snap install kubeadm kubelet kubetcl kubernetes-cnl

```