resource "openstack_networking_secgroup_v2" "default" {
  name        = "default"
  description = "Default security group"
}

resource "openstack_networking_secgroup_rule_v2" "5b5ba328-f5f5-4930-8afb-437502e859f8" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_ip_prefix  = "10.0.0.0/8"
  port_range_min    = "22"
  port_range_max    = "22"
  security_group_id = "${openstack_networking_secgroup_v2.default.id}"
}

resource "openstack_networking_secgroup_rule_v2" "64b3260d-30a7-43b6-a4ae-06fcadb0791f" {
  direction         = "egress"
  ethertype         = "IPv6"
  security_group_id = "${openstack_networking_secgroup_v2.default.id}"
}

resource "openstack_networking_secgroup_rule_v2" "8bbbf949-a3d5-4a42-93ab-9c0cf27e9ea4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  security_group_id = "${openstack_networking_secgroup_v2.default.id}"
}

resource "openstack_networking_secgroup_rule_v2" "ad7d43ac-e4de-4b82-b03f-44e89a32edaf" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.default.id}"
}

resource "openstack_networking_secgroup_rule_v2" "e9412f41-727b-4ef1-a8ba-d465dec63910" {
  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = "${openstack_networking_secgroup_v2.default.id}"
}

resource "openstack_networking_secgroup_rule_v2" "f5f2ec12-e90f-469c-810d-c6689269bd41" {
  direction         = "ingress"
  ethertype         = "IPv6"
  security_group_id = "${openstack_networking_secgroup_v2.default.id}"
}
