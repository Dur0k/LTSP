# Guide to setup the Linux Terminal Server Project (LTSP)
## About
This guide will walk through the steps needed to setup LTSP inside a virtual machine (VM).

## Prerequisites
A server with working virtualisation and functioning hardware passthrough is needed. Libvirt and QEMU is a usable combination for this purpose. 
For the VM a dedicated Network interface controller (NIC) is needed. To improve performance the whole controller will be passed through to the VM.

## Installation
### VM setup
Inline-style: 
!(https://durok.tech/gitea/durok/LTSP/src/branch/master/src/common/images/VM1.png "Logo Title Text 1")
## Push to git
git add *

git commit -m “Commit message”

git push origin master
