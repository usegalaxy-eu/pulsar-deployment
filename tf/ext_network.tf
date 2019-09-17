data "openstack_networking_network_v2" "external" {
  name = "${var.public_network}"
}
