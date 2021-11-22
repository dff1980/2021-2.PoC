
resource "vsphere_virtual_machine" "rancher_nodes" {
  count = length(var.rancher_nodes_ip)
  depends_on = [resource.vsphere_folder.folder]
  
  name             = "${var.rancher_nodes_settings.vm_node_name}-${count.index}"
#  resource_pool_id = data.vsphere_resource_pool.pool.id
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder = resource.vsphere_folder.folder.path

  num_cpus = 2
  memory   = 8192

  network_interface {
    network_id = resource.vsphere_distributed_port_group.dpg.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  wait_for_guest_net_timeout = -1
  wait_for_guest_ip_timeout  = -1

 scsi_type = data.vsphere_virtual_machine.template.scsi_type
 
  disk {
    label            = "disk0"
    size             = 64
    #size = data.vsphere_virtual_machine.template.disks.0.size
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

    guest_id = data.vsphere_virtual_machine.template.guest_id
    firmware = data.vsphere_virtual_machine.template.firmware

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id 
  }

  extra_config = {
    "guestinfo.metadata"          = base64gzip(data.template_file.metadata[count.index].rendered)
    "guestinfo.metadata.encoding" = "gzip+base64"
    "guestinfo.userdata"          = base64gzip(data.template_file.userdata_rancher.rendered)
    "guestinfo.userdata.encoding" = "gzip+base64"
  }

}

resource "vsphere_virtual_machine" "router" {
  depends_on = [resource.vsphere_folder.folder]
  name             = "router"

#  resource_pool_id = data.vsphere_resource_pool.pool.id
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id  
  datastore_id     = data.vsphere_datastore.datastore.id
  folder = resource.vsphere_folder.folder.path

  num_cpus = 1
  memory   = 2048

  network_interface {
    network_id = resource.vsphere_distributed_port_group.dpg.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  network_interface {
    network_id = data.vsphere_network.wan.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  wait_for_guest_net_timeout = -1
  wait_for_guest_ip_timeout  = -1
  
  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  disk {
    label            = "disk0"
    size             = 128
    #size = data.vsphere_virtual_machine.template.disks.0.size
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

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