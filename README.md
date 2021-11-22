# 2021-1.PoC
Rancher 2.6 PoC

#terraform, #salt, #RKE, #Rancher

###### Current state: automatically create virtual Mashines and preconfigure SLES for installing RKE, Ranche.
###### Road Map: Configure Nпinx (forgot to write the config) for LB, Configure RKE and Rancher

## Create VMware vSphere cluster for RKE cluster & Rancher using Terraform

This project is PoC installation Rancher at SLES .

Using version:
- RKE
- Rancher 2.x
- SLES 15 SP3

This document currently in development state. Any comments and additions are welcome.
If you need some additional information about it please contact with Pavel Zhukov (pavel.zhukov@suse.com).

###### Disclaimer
###### _At the moment, no one is responsible if you try to use the information below for productive installations or commercial purposes._

## PoC Landscape
PoC can be deployed in VMware virtualization environment.

Currently, PoC use terraform for create virtual mashine and pre-configure and salt for configure router, nat, firewalld, DHCP server, DNS server, NTP server and pre-configure nodes for install RKE and Rancher.

## Requarments

VMware vSphere infrastructure enviroment.

SLES15-SP3-JeOS.x86_64-15.3-VMware-GM.vmdk.xz

SUSE SLES trial key.

SSH public key to login to infrastructure server (optional)

Current PoC use DVS and create DPG for installation. (and don't use pool). You need some change if you use regular virtual network instead of DVS.

### Tech Specs
- 1 dedicated infrastructure server ( DNS, DHCP, NTP, NAT, RKE admin, Rancher admin) - created automatically 
    
    2GB RAM
    
    1 x HDD - 128GB
    
    1 LAN adapter
    
    1 WAN adapter

- 1 x RKE for Rancher Server Nodes 
  
  - 1 x  Node (Up to 3  nodes)  - created automatically
  
     2 VCPUS
     
     8 GB RAM
  
     1 x HDD 64 GB (50 GB+)
  
     1 LAN (Minimum 1Gb/s)
  
- 1-3 (or more) x RKE Node for demo
    
     4 - 32 GB RAM
     
     1 x HDD 24 GB (or more)
     
     1 LAN

### Network Architecture
All server connect to LAN network (isolate from another world). In current state - 192.168.14.0/24.
Infrastructure server also connects to WAN. 
Created automatically.

## Create VMware template (virtual mashine) with SLES15 SP3

Create virtual mashine using SLES15-SP3-JeOS.x86_64-15.3-VMware-GM.vmdk.xz

Start that VM and configure.

Registry server using Trial key.
```bash

```
run next:
```bash
SUSEConnect --product sle-module-public-cloud/15.3/x86_64
zypper in -y cloud-init
systemctl enable cloud-init-local.service
systemctl enable cloud-init.service
systemctl enable cloud-config.service
systemctl enable cloud-final.service

```
### Install at node template cloud-init-vmware-guestinfo

```bash
curl -sSL https://raw.githubusercontent.com/vmware/cloud-init-vmware-guestinfo/master/install.sh | sh -
```
or
```bash
zypper in -y python3-pip
wget https://github.com/vmware-archive/cloud-init-vmware-guestinfo/archive/refs/tags/v1.4.1.tar.gz
tar -zxf v1.4.1.tar.gz
cd cloud-init-vmware-guestinfo-1.4.1/
./install.sh
```

Do not use below metod (because this doesn't  work)
```
SUSEConnect -p PackageHub/15.2/x86_64
zypper install cloud-init-vmware-guestinfo
```

### Clenup Install for creating teamplates

```bash
sudo cloud-init clean
SUSEConnect -d
SUSEConnect --cleanup

sudo zypper install -y clone-master-clean-up
clone-master-clean-up
```

## Install Terraform at admin node (SLES15 SP2)
Standart way, but old version can't use some features
```
SUSEConnect --product sle-module-public-cloud/15.2/x86_64
zypper in terraform
```
best way download form
https://www.terraform.io/downloads.html
and put app to ~/bin/

## Configure variable for current instalation in terraform.tfvars
## User system variable as terraform variable
```
   export TF_VAR_vsphere_credetial='{ user="administrator@vsphere.local", password="password", server="server.fqdn.lan" }'
   export TF_VAR_ssh_public_key="ssh-rsa AAAAA"
   export TF_VAR_registry_key="KEY-KEY-KEY"
```

## Terraform Init, Plan, Apply, Destroy

cd to terraform folder

```
terraform init
terraform plan
terraform apply
terraform destroy
```

## Appendix

### Links
https://github.com/linoproject/terraform/tree/master/rancher-lab

https://blog.linoproject.net/cloud-init-with-terraform-in-vsphere-environment-a-step-forward/

not necessary

https://kb.vmware.com/s/article/59557


other staff need to systematize

 example count https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/resources/host_port_group
 
 example count https://habr.com/ru/company/piter/blog/496820/
 
 example cloud-init https://grantorchard.com/dynamic-cloudinit-content-with-terraform-file-templates/

 ###Garbage 
 
 https://www.infralovers.com/en/articles/2021/01/21/vmware-templates-with-terraform-and-cloud-init
 
 https://rpadovani.com/terraform-cloudinit
 
 https://github.com/hashicorp/terraform/issues/4668

 https://github.com/linoproject/terraform/tree/master/rancher-lab

    - content: |
    
        # Salt - one-time modification performed on {{ salt['cmd.run']('date') }}



