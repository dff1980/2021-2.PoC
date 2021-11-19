provider "vsphere" {
  vsphere_server = var.vsphere_credetial.server
  user           = var.vsphere_credetial.user
  password       = var.vsphere_credetial.password

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = var.vsphere_environment.datacenter
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphere_environment.cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

/*
data "vsphere_resource_pool" "pool" {
  name          = var.vsphere_environment.pool
  datacenter_id = data.vsphere_datacenter.dc.id
}
*/

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_environment.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_host" "host" {
  name          = var.vsphere_environment.host
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = "/${var.vsphere_environment.datacenter}/vm/${var.template_name}"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_distributed_virtual_switch" "dvs" {
  name          = var.vsphere_environment.dvs
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "wan" {
  name          = var.vsphere_environment.wan
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_distributed_port_group" "dpg" {
  name           = var.vsphere_environment.dpg
  distributed_virtual_switch_uuid = data.vsphere_distributed_virtual_switch.dvs.id

  vlan_id = var.vsphere_environment.dpg_vlan_id
}

data "vsphere_folder" "parent_folder" {
  path = var.vsphere_environment.parent_folder
}

resource "vsphere_folder" "folder" {
  path          = "${data.vsphere_folder.parent_folder.path}/${var.vsphere_environment.folder}"
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}
