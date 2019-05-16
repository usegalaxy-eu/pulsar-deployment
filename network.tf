resource "openstack_networking_network_v2" "internal" {
  name           = "${var.private_network}"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "internal" {
  name        = "${var.private_network}"
  network_id  = "${openstack_networking_network_v2.internal.id}"
  cidr        = "192.168.199.0/24"
  ip_version  = 4
  enable_dhcp = true
}