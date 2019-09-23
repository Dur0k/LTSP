# Guide to setup the Linux Terminal Server Project (LTSP)
## About
This guide will walk through the steps needed to setup LTSP inside a virtual machine (VM).

## Prerequisites
A server with working virtualisation and functioning hardware passthrough is needed. Libvirt and QEMU is a usable combination for this purpose. 
For the VM a dedicated Network interface controller (NIC) is needed. To improve performance the whole controller will be passed through to the VM.

## Installation
### VM setup
In the following the process of setting up the VM is described. 
Choose the desired installation media. In this case an ISO is used.
![VM1](https://durok.tech/gitea/durok/LTSP/raw/branch/master/src/common/images/VM1.png)

![VM1](https://durok.tech/gitea/durok/LTSP/raw/branch/master/src/common/images/VM2.png)


## Push to git
git add *

git commit -m “Commit message”

git push origin master
