# Guide to setup the Linux Terminal Server Project (LTSP)
## About
This guide will walk through the steps needed to setup LTSP inside a virtual machine (VM).

## Prerequisites
A server with working virtualisation and functioning hardware passthrough is needed. Libvirt and QEMU is a usable combination for this purpose. 
For the VM a dedicated Network interface controller (NIC) is needed. To improve performance the whole controller will be passed through to the VM.

## Installation
### VM setup
In the following the process of setting up the VM is described. 
Choose the desired installation media. In this case a Ubuntu 18.04 server ISO is used.

![VM1](https://durok.tech/gitea/durok/LTSP/raw/branch/master/src/common/images/VM1.png)
![VM2](https://durok.tech/gitea/durok/LTSP/raw/branch/master/src/common/images/VM2.png)

Afterwards create the disk image to be used for the VM.

![VM3](https://durok.tech/gitea/durok/LTSP/raw/branch/master/src/common/images/VM3.png)
![VM4](https://durok.tech/gitea/durok/LTSP/raw/branch/master/src/common/images/VM4.png)

Now you can review your settings and choose the *Customize configuration before install* option.

Choose the i440FX chipset and the OVMF UEFIx86_64 firmware.

![VM5](https://durok.tech/gitea/durok/LTSP/raw/branch/master/src/common/images/VM5.png)

Finish the setup and install Ubuntu 18.04 server.

### Update the VM
```bash
sudo apt update && sudo apt upgrade -y
```

### Install openssh server
Install the openssh server with apt 
```bash
sudo apt install ssh
```
and enable the systemd service with
```bash
sudo systemctl enable ssh
```
.

### Remove netplan and revert back to ifupdown
Reinstall the **ifupdown** package:
```bash
sudo apt install ifupdown
```

Configure the **/etc/network/interfaces** file with the desired configuration:

`/etc/network/interfaces`
```bash
# The loopback network interface
auto lo
iface lo inet loopback

# Change eth0 with the correct network interface name
allow-hotplug eth0
auto eth0
iface eth0 inet dhcp
```

To view all network interfaces use the `ip a` command.

Enable ifupdown:
```bash
sudo ifdown --force eth0 lo && ifup -a
sudo systemctl unmask networking
sudo systemctl enable networking
sudo systemctl restart networking
```

Disable and remove netplan services:
```bash
sudo systemctl stop systemd-networkd.socket systemd-networkd networkd-dispatcher systemd-networkd-wait-online
sudo systemctl disable systemd-networkd.socket systemd-networkd networkd-dispatcher systemd-networkd-wait-online
sudo systemctl mask systemd-networkd.socket systemd-networkd networkd-dispatcher systemd-networkd-wait-online
sudo apt-get --assume-yes purge nplan netplan.io
```

Afterwards add a DNS server to 
`/etc/systemd/resolved.conf`
```bash
[Resolve]
DNS=1.1.1.1
DNS=1.0.0.1
```
.
This is needed by the DNS stub resolver as provided by SYSTEMD-RESOLVED.SERVICE(8).
Now restart the systemd-resolved service
```bash
sudo systemctl restart systemd-resolved
```

### Install LTSP
Add the Greek schools repository and update.
```bash
sudo add-apt-repository --yes ppa:ts.sch.gr
sudo apt update
```

Install LTSP in chroot mode FIXME
```bash
sudo apt install --yes --install-recommends ltsp-server-standalone epoptes
```

Add your user to the epoptes group for later management
```bash
sudo gpasswd -a ${SUDO_USER:-$USER} epoptes
```

## Push to git
git add *

git commit -m “Commit message”

git push origin master
