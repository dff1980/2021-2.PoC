variable "vsphere_credetial" {
  type = object({
    server = string
    user = string
    password = string
  })
  sensitive = true
}

variable "vsphere_environment" {
  type = object({
    datacenter = string
    datastore = string
    cluster = string
    host = string
    dvs = string
    dpg = string
    dpg_vlan_id = string
    wan = string
    parent_folder = string
    folder = string
  })
}

variable "template_name" {
  description = "Node template name (ie: image_path)"
  type = string
}

variable "rancher_nodes_ip" {
  type = list(string)
  description = "Rancher Nodes IP adress"
}

variable "rancher_nodes_settings" {
  type = object({
    rancher_nodes_hostname = string
    vm_node_name = string
    router_ip = string
    username = string
    domain = string
    netmask = string
    network = string
  }) 
}

variable "ssh_public_key" {
  type    = string
  default = ""
  sensitive = true
}

variable "general_ssh_public_key" {
  type    = string
  default = ""
  sensitive = true
}

variable "ssh_private_key" {
  type    = string
  default = ""
  sensitive = true
}

variable "registry_key" {
  description = "SLES Registry Key"
  type        = string
  sensitive   = true
}