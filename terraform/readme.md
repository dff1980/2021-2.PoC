# Create VMware vSphere RKE cluster using Terraform
## User system variable as terraform variable
```
 export TF_VAR_vsphere_password="password"
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

## Install at node template cloud-init-vmware-guestinfo

does not work
```
SUSEConnect -p PackageHub/15.2/x86_64
zypper install cloud-init-vmware-guestinfo
```
work version
```
curl -sSL https://raw.githubusercontent.com/vmware/cloud-init-vmware-guestinfo/master/install.sh | sh -
```

## Terraform Init, Plan, Apply, Destroy
```
terraform init
terraform plan
terraform apply
terraform destroy
```

## Appendix
### Only add vSphere terraform provider
make directory terraform-admin

```
mkdir -p terraform-admin
```

create file main.tf in terraform-admin

```
cd terraform-admin
cat << EOF > main.tf
terraform {
  required_providers {
    vsphere = {
      source = "hashicorp/vsphere"
      version = "1.24.3"
    }
  }
}

provider "vsphere" {
  # Configuration options
}
EOF
```
run terraform init
```
terraform init
```

### Links
https://github.com/linoproject/terraform/tree/master/rancher-lab

https://blog.linoproject.net/cloud-init-with-terraform-in-vsphere-environment-a-step-forward/

not necessary

https://kb.vmware.com/s/article/59557

