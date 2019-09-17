data "openstack_networking_network_v2" "internal" {
  name = "${var.private_network["name"]}"
}
