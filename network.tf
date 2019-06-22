resource "openstack_networking_network_v2" "internal" {
  name           = "${var.private_network["name"]}"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "internal" {
  name        = "${var.private_network["subnet_name"]}"
  network_id  = "${openstack_networking_network_v2.internal.id}"
  cidr       = "${var.private_network["cidr4"]}"
  ip_version  = 4
  enable_dhcp = true
}

data "openstack_networking_network_v2" "external" {
  name = "${var.public_network}"
}


resource "openstack_networking_router_v2" "router_1" {
  name                = "${var.name_prefix}router"
  external_network_id = "${data.openstack_networking_network_v2.external.id}"
}

resource "openstack_networking_router_interface_v2" "router_interface_1" {
  router_id = "${openstack_networking_router_v2.router_1.id}"
  subnet_id = "${openstack_networking_subnet_v2.internal.id}"
}
