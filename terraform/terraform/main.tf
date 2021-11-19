provider "vsphere" {
  vsphere_server = var.vsphere_server
  user           = var.vsphere_user
  password       = var.vsphere_password

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = var.datacenter
}


data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

#data "vsphere_resource_pool" "pool" {
#  name          = var.pool
#  datacenter_id = data.vsphere_datacenter.dc.id
#}

data "vsphere_datastore" "datastore" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_host" "host" {
  name          = var.host
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = "/${var.datacenter}/vm/${var.template_name}"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_distributed_virtual_switch" "dvs" {
  name          = var.dvs
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "wan" {
  name          = var.wan
  datacenter_id = data.vsphere_datacenter.dc.id
}


resource "vsphere_distributed_port_group" "dpg" {
  name           = var.dpg
  distributed_virtual_switch_uuid = data.vsphere_distributed_virtual_switch.dvs.id

  vlan_id = var.dpg_vlan_id
}

#data "vsphere_network" "rancher" {
#  name          = var.dpg
#  datacenter_id = data.vsphere_datacenter.dc.id
#}

data "vsphere_folder" "parent_folder" {
  path = var.parent_folder
}

resource "vsphere_folder" "folder" {
  path          = "${data.vsphere_folder.parent_folder.path}/${var.folder}"
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

#data "vsphere_folder" "folder" {
#  path          = var.folder
#}

resource "vsphere_virtual_machine" "rancher_nodes" {
  count = length(var.rancher_node_ip)
  depends_on = [resource.vsphere_folder.folder, vsphere_virtual_machine.router]
  
  name             = "${var.mv_node_name}-${count.index}"
#  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
#  resource_pool_id = data.vsphere_resource_pool.pool.id
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder = resource.vsphere_folder.folder.path

  num_cpus = 2
  memory   = 8192

  network_interface {
    network_id = resource.vsphere_distributed_port_group.dpg.id
  }

  wait_for_guest_net_timeout = -1
  wait_for_guest_ip_timeout  = -1

 scsi_type = data.vsphere_virtual_machine.template.scsi_type
 
  disk {
    label            = "disk0"
    #thin_provisioned = true
    size             = 64
    ##eagerly_scrub = false
    #size = data.vsphere_virtual_machine.template.disks.0.size
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  #guest_id = "sles15_64Guest"
    guest_id = data.vsphere_virtual_machine.template.guest_id
    firmware = data.vsphere_virtual_machine.template.firmware

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id 
  }


  extra_config = {
    "guestinfo.metadata"          = base64gzip(data.template_file.metadata[count.index].rendered)
    "guestinfo.metadata.encoding" = "gzip+base64"
    "guestinfo.userdata"          = base64gzip(data.template_file.userdata[count.index].rendered)
    "guestinfo.userdata.encoding" = "gzip+base64"
  }

}

resource "vsphere_virtual_machine" "router" {
  depends_on = [resource.vsphere_folder.folder]
  name             = "router"

#  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
#  resource_pool_id = data.vsphere_resource_pool.pool.id
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id  
  datastore_id     = data.vsphere_datastore.datastore.id
  folder = resource.vsphere_folder.folder.path

  num_cpus = 1
  memory   = 2048

  network_interface {
    network_id = resource.vsphere_distributed_port_group.dpg.id
  }

  network_interface {
    network_id = data.vsphere_network.wan.id
  }

  wait_for_guest_net_timeout = -1
  wait_for_guest_ip_timeout  = -1
  
  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  disk {
    label            = "disk0"
    #thin_provisioned = true
    size             = 128
    ##eagerly_scrub = false
    #size = data.vsphere_virtual_machine.template.disks.0.size
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  #guest_id = "sles15_64Guest"
    guest_id = data.vsphere_virtual_machine.template.guest_id
    firmware = data.vsphere_virtual_machine.template.firmware

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id 
  }


  extra_config = {
    "guestinfo.metadata"          = base64gzip(data.template_file.metadata_router.rendered)
    "guestinfo.metadata.encoding" = "gzip+base64"
    "guestinfo.userdata"          = base64gzip(data.template_file.userdata_router.rendered)
    "guestinfo.userdata.encoding" = "gzip+base64"
  }

}