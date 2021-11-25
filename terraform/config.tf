locals {

  registration_cmd =  "SUSEConnect -e pzhukov@suse.com -r ${var.registry_key}"

  runcmd_router = <<EOT
   - SUSEConnect -e pzhukov@suse.com -r ${var.registry_key}
   - zypper ref
   - ssh-keygen -N "" -f /root/.ssh/id_rsa
   - sed -i 's/PubkeyAuthentication\s*no/PubkeyAuthentication yes/' /etc/ssh/sshd_config
   - systemctl restart sshd
   - mkdir -p /srv/salt/ssh
   - cp /root/.ssh/id_rsa.pub /srv/salt/ssh/
   - cp /root/.ssh/id_rsa.pub /home/sles/.ssh/
   - chown sles:users /home/sles/.ssh/id_rsa.pub
   - salt-call --local state.apply
   - zypper in -y salt-master
   - systemctl enable salt-master --now
   - systemctl enable salt-minion --now
EOT

  runcmd_rancher = <<EOT
   - bash /tmp/dns_servers_crutch.sh
   - rm /tmp/dns_servers_crutch.sh
   - systemctl enable salt-minion --now
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
    content      = data.template_file.userdata_rancher.rendered
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

data template_file "userdata_rancher" {
  template = file("${path.module}/templates/userdata_rancher.yaml")
  
  vars = {
    username                   = var.rancher_nodes_settings.username
    ssh_public_key             = var.ssh_public_key
    router_ip          = var.rancher_nodes_settings.router_ip
    runcmd             = local.runcmd_rancher
    salt_rancher_conf                = filebase64("${path.module}/salt/minion/rancher.conf")
    salt_autosign_grains_conf        = filebase64("${path.module}/salt/minion/autosign-grains.conf")
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
    username                   = var.rancher_nodes_settings.username
    ssh_public_key             = var.ssh_public_key
    runcmd_router       = local.runcmd_router
    registration_cmd    = local.registration_cmd
    salt_top_sls        = filebase64("${path.module}/salt/salt/top.sls")
    salt_router_sls     = filebase64("${path.module}/salt/salt/router.sls")
    salt_rancher_sls    = filebase64("${path.module}/salt/salt/rancher.sls")
    salt_rke_sls        = filebase64("${path.module}/salt/salt/rke.sls")
    salt_ssh-key_sls        = filebase64("${path.module}/salt/salt/ssh-key.sls")
    salt_router_chrony          = filebase64("${path.module}/salt/salt/router/ntp.conf")
    salt_router_dhcpd_conf      = filebase64("${path.module}/salt/salt/router/dhcpd.conf")
    salt_router_rancher_suse_ru = filebase64("${path.module}/salt/salt/router/stend.suse.ru")
    salt_router_addr_arpa       = filebase64("${path.module}/salt/salt/router/14.168.192.in-addr.arpa")
    salt_main_ntp                    = filebase64("${path.module}/salt/salt/main/ntp.conf")
    salt_reactor_start               = filebase64("${path.module}/salt/reactor/start.sls")
    salt_reactor_delkey              = filebase64("${path.module}/salt/reactor/delkey.sls")
    salt_master_conf                 = filebase64("${path.module}/salt/master/router.conf")
    salt_autosign_key                = filebase64("${path.module}/salt/master/autosign_key")
    salt_router_conf                 = filebase64("${path.module}/salt/minion/router.conf")
    salt_autosign_grains_conf        = filebase64("${path.module}/salt/minion/autosign-grains.conf")
    
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