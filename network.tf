data "openstack_networking_network_v2" "external" {
  name = "${var.public_network}"
}

data "openstack_networking_network_v2" "internal" {
  name = "${var.private_network["name"]}"
}
