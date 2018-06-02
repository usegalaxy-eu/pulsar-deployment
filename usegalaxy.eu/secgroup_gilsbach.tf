resource "openstack_networking_secgroup_v2" "Gilsbach_webserver" {
  name        = "Gilsbach webserver"
  description = "Open port 8080 and 8081."
}

resource "openstack_networking_secgroup_rule_v2" "28200afa-3a70-492c-bf80-b000eef55f0a" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  port_range_min    = "8081"
  port_range_max    = "8081"
  security_group_id = "${openstack_networking_secgroup_v2.Gilsbach_webserver.id}"
}

resource "openstack_networking_secgroup_rule_v2" "66846d2b-67df-4ab6-bbda-5b38cb942c0f" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  port_range_min    = "8080"
  port_range_max    = "8080"
  security_group_id = "${openstack_networking_secgroup_v2.Gilsbach_webserver.id}"
}
