#output "vm_ip" {
#  value = vsphere_virtual_machine.tf_node_test.guest_ip_addresses
#}

output metadata {
  value = "\n${data.template_file.metadata[0].rendered}"
}

output userdata {
  value = "\n${data.template_file.userdata[0].rendered}"
}