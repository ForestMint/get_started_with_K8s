# ☸️ A simple training to run a K8s custer

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

## 🖥 Power the machines on

in each folder (./master, ./worker-1, ./worker-2), run the following commands

```sh
$ vagrant up
```

## 🔐 Setup SSH

in each folder (./master, ./worker-1, ./worker-2), run the following commands

```sh
$ vagrant ssh
```
