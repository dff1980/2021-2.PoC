locals {
  runcmd = <<EOT
   - SUSEConnect -e pzhukov@suse.com -r ${var.registry_key}
EOT

  runcmd_router = <<EOT
   - SUSEConnect -e pzhukov@suse.com -r ${var.registry_key}
EOT

gateway = var.router_ip

nameservers = [
  var.router_ip
]

}

 # example count https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/resources/host_port_group
 # example count https://habr.com/ru/company/piter/blog/496820/
 # example cloud-init https://grantorchard.com/dynamic-cloudinit-content-with-terraform-file-templates/
 # https://www.infralovers.com/en/articles/2021/01/21/vmware-templates-with-terraform-and-cloud-init/
 # https://rpadovani.com/terraform-cloudinit
 # https://github.com/hashicorp/terraform/issues/4668
 # https://github.com/linoproject/terraform/tree/master/rancher-lab

 data "template_cloudinit_config" "userdata" {
     count = length(var.rancher_node_ip) 
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = data.template_file.userdata[count.index].rendered
  }
}

 data "template_cloudinit_config" "metadata" {
     count = length(var.rancher_node_ip)
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = data.template_file.metadata[count.index].rendered
  }
}

 data "template_cloudinit_config" "userdata_router" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = data.template_file.userdata_router.rendered
  }
}

 data "template_cloudinit_config" "metadata_router" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = data.template_file.metadata_router.rendered
  }
}



data template_file "userdata" {
    count = length(var.rancher_node_ip)
  template = file("${path.module}/templates/userdata.yaml")

  vars = {
    username           = var.username
    ssh_public_key     = var.ssh_public_key
    packages           = jsonencode(var.packages)
    runcmd             = local.runcmd
  }
}

data template_file "metadata" {
    count = length(var.rancher_node_ip)
  template = file("${path.module}/templates/metadata.yaml")
  vars = {
    hostname    = "${var.rancher_node_hostname}-${count.index}"
    ip_address  = var.rancher_node_ip[count.index]
    netmask     = var.netmask
    nameservers = jsonencode(local.nameservers)
    gateway     = local.gateway
  }
}

data template_file "userdata_router" {
  template = file("${path.module}/templates/userdata_router.yaml")

  vars = {
    username           = var.username
    ssh_public_key     = var.ssh_public_key
    runcmd             = local.runcmd_router
  }
}

data template_file "metadata_router" {
  template = file("${path.module}/templates/metadata_router.yaml")
  vars = {
    hostname    = "router"
    ip_address  = var.router_ip
    netmask     = var.netmask
    nameservers = jsonencode(local.nameservers)
  }
}