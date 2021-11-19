variable "vsphere_server" {
  description = "vSphere server"
  type        = string
}

variable "vsphere_user" {
  description = "vSphere username"
  type        = string
}

variable "vsphere_password" {
  description = "vSphere password"
  type        = string
  sensitive   = true
}

variable "datacenter" {
  description = "vSphere data center"
  type        = string
}

variable "cluster" {
  description = "vSphere cluster"
  type        = string
}

/*
variable "pool" {
  description = "vSphere pool"
  type        = string
}
*/
variable "parent_folder" {
  description = "vSphere Folder"
  type        = string
}
variable "folder" {
  description = "vSphere Folder"
  type        = string
}

variable "host" {
  description = "vSphere host"
  type        = string
}

variable "mv_node_name" {
  description = "vSphere VM Name"
  type        = string
}

variable "datastore" {
  description = "vSphere datastore"
  type        = string
}

variable "dvs" {
  description = "vSphere Distributed Virtual Switch"
  type        = string
}

variable "dpg" {
  description = "vSphere Distributed Port Group Name"
  type        = string
}

variable "dpg_vlan_id" {
  description = "vSphere Distributed Port Group VLAN ID"
  type        = string
}

variable "wan" {
  description = "vSphere Distributed Port Group Wan Name"
  type        = string
}

variable "template_name" {
  description = "Node template name (ie: image_path)"
  type        = string
}

variable "rancher_node_ip" {
  default = [
    "192.168.14.101",
    "192.168.14.101",
    "192.168.14.101",
  ]
}

variable "rancher_node_hostname" {
  description = "Rancher Nodes hostname prefix"
  type        = string  
  default = "rancher-node"
}

variable "router_ip" {
  description = "Router IP"
  type        = string  
  default = "192.168.14.254"
}

variable "username" {
  type    = string
  default = "sles"
}

variable "ssh_public_key" {
  type    = string
  default = ""
  sensitive = true
}

variable "packages" {
  type    = list
  default = [
    "docker"
  ]
}

variable "registry_key" {
  description = "SLES Registry Key"
  type        = string
  sensitive   = true
}

variable domain {
  type = string
  default = ""
}

variable netmask {
  type = string
  default = ""
}
