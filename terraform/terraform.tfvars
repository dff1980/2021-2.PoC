 vsphere_environment = {
    datacenter         = "DC01_Local"
    datastore          = "vhost01_Datastore_02"
    cluster            = "Cluster"
    #pool               = "Office"
    host               = "172.29.192.21"
    dvs                = "DSwitch 01"
    dpg                = "DPG_PZhukov_Rancher26_TF_LAB_VLAN1301"
    dpg_vlan_id        = "1301"
    wan                = "DPG_Zhukov_Lab_VLAN13"
    parent_folder      = "PZhukov"
    folder             = "pzhukov-rancher-tf"
}

rancher_nodes_ip = [
    "11",
    "12",
    "13",
]

rancher_nodes_settings = {
    rancher_nodes_hostname = "rancher-node"
    vm_node_name           = "rancher_node"
    router_ip              = "192.168.14.254"
    username               = "sles"
    domain                 = "stend.suse.ru"
    network                = "192.168.14"
    netmask                = "24"
}

#registry_key       = ""
#ssh_public_key     = ""

template_name      = "PZhukov/2021.1-PoC/node-template"
