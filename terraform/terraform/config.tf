locals {
  runcmd = <<EOT
   - bash /tmp/dns_servers_crutch.sh
   - rm /tmp/dns_servers_crutch.sh
EOT

gateway = var.rancher_nodes_settings.router_ip

nameservers = [
  var.rancher_nodes_settings.router_ip
]

}
 data "template_cloudinit_config" "userdata" {

  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = data.template_file.userdata.rendered
  }
}

 data "template_cloudinit_config" "metadata" {
  count = length(var.rancher_nodes_ip)

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
  template = file("${path.module}/templates/userdata.yaml")
  
  vars = {
    username           = var.rancher_nodes_settings.username
    ssh_public_key     = var.ssh_public_key
    router_ip          = var.rancher_nodes_settings.router_ip
    runcmd             = local.runcmd
  }
}

data template_file "metadata" {
  count = length(var.rancher_nodes_ip)
  template = file("${path.module}/templates/metadata.yaml")
  vars = {
    hostname    = "${var.rancher_nodes_settings.rancher_nodes_hostname}-${count.index}"
    ip_address  = "${var.rancher_nodes_settings.network}.${var.rancher_nodes_ip[count.index]}"
    netmask     = var.rancher_nodes_settings.netmask
    nameservers = jsonencode(local.nameservers)
    gateway     = local.gateway
  }
}

data template_file "userdata_router" {
  template = file("${path.module}/templates/userdata_router.yaml")

  vars = {
    username           = var.rancher_nodes_settings.username
    ssh_public_key     = var.ssh_public_key
    runcmd_router      = var.scripts.runcmd
    install_packages   = file("${path.module}/router_scripts/${var.scripts.install_packages}")
    chrony_setup       = file("${path.module}/router_scripts/${var.scripts.chrony_setup}")
    dhcpd_setup        = file("${path.module}/router_scripts/${var.scripts.dhcpd_setup}")
    named_setup        = file("${path.module}/router_scripts/${var.scripts.named_setup}")
    firewall_setup     = file("${path.module}/router_scripts/${var.scripts.firewall_setup}")
  }
}

data template_file "metadata_router" {
  template = file("${path.module}/templates/metadata_router.yaml")
  vars = {
    hostname    = "router"
    ip_address  = var.rancher_nodes_settings.router_ip
    netmask     = var.rancher_nodes_settings.netmask
    nameservers = jsonencode(local.nameservers)
  }
}