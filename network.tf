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
