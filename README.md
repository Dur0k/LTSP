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

Under CPUs tick the Copy host CPU configuration option.
Finish the setup and install Ubuntu 18.04 server.

### Update the VM
```
sudo apt update && sudo apt upgrade -y
```

### Install openssh server
Install the openssh server with apt 
```
sudo apt install ssh
```
and enable the systemd service with
```
sudo systemctl enable ssh
```


### Remove netplan and revert back to ifupdown
Reinstall the **ifupdown** package:
```
sudo apt install ifupdown
```

Configure the **/etc/network/interfaces** file with the desired configuration: FIXME better with static

`/etc/network/interfaces`
```
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
```
sudo ifdown --force eth0 lo && ifup -a
sudo systemctl unmask networking
sudo systemctl enable networking
sudo systemctl restart networking
```

Disable and remove netplan services:
```
sudo systemctl stop systemd-networkd.socket systemd-networkd networkd-dispatcher systemd-networkd-wait-online
sudo systemctl disable systemd-networkd.socket systemd-networkd networkd-dispatcher systemd-networkd-wait-online
sudo systemctl mask systemd-networkd.socket systemd-networkd networkd-dispatcher systemd-networkd-wait-online
sudo apt-get --assume-yes purge nplan netplan.io
```

Afterwards add a DNS server to 

`/etc/systemd/resolved.conf`
```
[Resolve]
.....
DNS=1.1.1.1
DNS=1.0.0.1
.....
```

This is needed by the DNS stub resolver as provided by SYSTEMD-RESOLVED.SERVICE(8).
Now restart the systemd-resolved service
```
sudo systemctl restart systemd-resolved
```

### Install LTSP
Add the Greek schools repository and update.
```
sudo add-apt-repository --yes ppa:ts.sch.gr
sudo apt update
```

Install LTSP in chroot mode FIXME
```
sudo apt install --yes --install-recommends ltsp-server-standalone epoptes
```

Add your user to the epoptes group for later management
```
sudo gpasswd -a ${SUDO_USER:-$USER} epoptes
```

### Create the client image

Create the client config
```
sudo ltsp-config lts.conf 
```

Build the client image
```
sudo su
ltsp-build-client --purge-chroot --mount-package-cache --extra-mirror 'http://ppa.launchpad.net/ts.sch.gr/ppa/ubuntu bionic main' \
  --apt-keys '/etc/apt/trusted.gpg.d/ts_sch_gr_ubuntu_ppa.gpg' --late-packages epoptes-client
```


### Configure networking with dnsmasq
The VM needs access to the internet either via a virtual NAT or another physical NIC. A second NIC is used to create the network and serve the image for the clients.
In the following the interface `ens3` is connected to the internet and `ens9` will serve the clients. For `ens9` a static ip address of 192.168.67.1 with the corresponding subnet will be used.

Edit the network configuration:
`/etc/network/interfaces`
```
# The loopback network interface
auto lo
iface lo inet loopback

# The server/internet facing interface
allow-hotplug ens3
auto ens3
iface ens3 inet dhcp

# The client serving interface with static address
allow-hotplug ens9
auto ens9
iface ens9 inet static
 address 192.168.67.1
 netmask 255.255.255.0
 broadcast 192.168.67.255
 gateway 192.168.67.1


```



Configure dnsmasq via a provided configuration

```
sudo ltsp-config dnsmasq --enable-dns --no-proxy-dhcp
```
Restart networking
```
sudo systemctl restart networking
```


Add or change the following entries:

`/var/lib/tftpboot/ltsp/*/lts.conf`
```
.....
[Default]
LDM_SESSION="xubuntu"
LDM_LANGUAGE="de_DE.UTF-8"
.....

.....
LDM_GUESTLOGIN=True
.....

.....
# Map HOSTNAMEs to LDM_USERNAMEs. E.g. for HOSTNAME=pc01, LDM_USERNAME=guest01.
HOSTNAME_BASE = "guest"
#HOST_TO_USERNAME="pc/guest"
.....

.....

.....
```

### Configure the client image
Install packages for the client image with the `ltsp-chroot` command
```
sudo ltsp-chroot -m apt install rsync xubuntu-desktop vlc gimp pinta libreoffice scratch geogebra nemo
```

Set german locale
`/opt/ltsp/amd64/etc/default/locale`
```
LANG=de_DE.UTF-8
LANGUAGE=de_DE
LC_ALL=de_DE.UTF-8
```

```
sudo ltsp-chroot locale-gen de_DE
sudo ltsp-chroot locale-gen de_DE.UTF-8
```

Install german language packages
```
sudo ltsp-chroot -m apt-get -y install $(check-language-support -l de)
```


After every change to the client, its image needs to be recreated
```
sudo ltsp-update-image
```

//FIXME better script
//https://gitlab.com/Virtual-LTSP/VirtualBox/raw/bionic/scripts/create-guest-accounts.sh

delete users
```
#!/bin/bash
basename=guest
for ip in {1..255}; do
        user="${basename}${ip}"
        deluser $user
done
```
Add a guest session which will be deleted after logout

`/opt/ltsp/amd64/usr/share/ldm/rc.d/S00-guest-sessions`
```
case "$LDM_USERNAME" in
    guest*)
        ssh -S "$LDM_SOCKET" "$LDM_SERVER" 'cd; rm -rf .* *; rsync -a /etc/skel/ .'
        ;;
esac
```


Create the corresponding guest accounts with the following script:
`guestsession.sh`
```bash
#!/bin/bash -x
### Create and config guest accounts.

guest="guest"
pass="guest"
hostname="guest"

# create the template/skeleton guest account
#groupadd guest --gid=500 -f
#adduser $guest --uid=500 --gid=500 \
#        --shell=/bin/bash --gecos '' \
#        --disabled-password
#usermod $guest --password="$(openssl passwd -stdin <<< $pass)"
#chown $guest:guest -R /home/$guest

# create the guest accounts
rm -rf /home/guest-accounts/
mkdir -p /home/guest-accounts/
for ip in {1..255}; do
    user="${hostname}${ip}"
    adduser $user --uid=$((500 + $ip)) --gid=500 \
            --home=/home/guest-accounts/$user \
            --shell=/bin/bash --gecos '' \
            --disabled-password
    usermod $user --password="$(openssl passwd -stdin <<< $user)"
done
```

Afterwards run it as root:
```
chmod +x guestsession.sh
sudo ./guestsession.sh
```


Options for the guest session can be changed in 

`/etc/skel/`

Permissions can be set with:
```
sudo chmod -R 755 /opt/ltsp/amd64/etc/skel/*
```


## Config files
`/etc/dnsmasq.d/ltsp-server-dnsmasq.conf`

`/etc/ltsp/dhcpd.conf`

`/var/lib/tftpboot/ltsp/*/lts.conf`


## More links
http://dashohoxha.fs.al/ltsp-scenarios/
## Push to git
git add *

git commit -m “Commit message”

git push origin master
