

#################### On master node, worker-1 and worker-2
vagrant up

check in VirtualBox machines's network settings that machine is attached to NAT

vagrant ssh
    ssh -V

    sudo systemctl enable ssh
    sudo systemctl start ssh

    sudo systemctl status ssh

    sudo adduser alice # set alice's password to "bubblegum"

    sudo usermod -aG sudo alice # add alice to sudoers

    sudo rm /etc/ssh/sshd_config

    sudo touch /etc/ssh/sshd_config

    sudo vim /etc/ssh/sshd_config
    paste the content of the ssh_config_template file of the repository into /etc/ssh/sshd_config

    uncomment 'AllowUsers alice' at line 21 to allow only alice to SSH into the machine, thus making vagrant ssh impossible
    If you leave it commented it will keep all the users allowed to SSH into the machine but we want this right to end for vagrant now

    sudo cat /etc/ssh/sshd_config | grep AllowUsers
    check AllowUsers

    ip a # to get the IP that will be available in the inet section of the output

    sudo reboot # seems to be needed to make changes in /etc/ssh/sshd_config acknowledged by the SSH daemon

from another terminal from your host machine
    ssh alice@<ip-node> # the password will be asked, it is "bubblegum"


