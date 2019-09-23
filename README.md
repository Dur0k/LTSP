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

Now you review your settings and choose the *Customize configuration before install* option.
![VM4](https://durok.tech/gitea/durok/LTSP/raw/branch/master/src/common/images/VM4.png)

Choose the i440FX chipset and the OVMF UEFIx86_64 firmware.
![VM5](https://durok.tech/gitea/durok/LTSP/raw/branch/master/src/common/images/VM5.png)

Finish the setup and install Ubuntu 18.04 server.

### Update the VM
```bash
sudo apt update && sudo apt upgrade -y
```


## Push to git
git add *

git commit -m “Commit message”

git push origin master
