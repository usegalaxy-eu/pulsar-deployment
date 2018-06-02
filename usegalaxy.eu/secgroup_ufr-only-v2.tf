resource "openstack_networking_secgroup_v2" "ufr-only-v2" {
  name        = "ufr-only-v2"
  description = "New ingress connections allowed only from UFR networks"
}

resource "openstack_networking_secgroup_rule_v2" "c1c92735-3199-42f6-bd0d-d5bc41026769" {
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_ip_prefix  = "192.52.3.0/24"
  security_group_id = "${openstack_networking_secgroup_v2.ufr-only-v2.id}"
}

resource "openstack_networking_secgroup_rule_v2" "ee64a152-317d-44cc-94a0-9b1da54bd2c7" {
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_ip_prefix  = "132.230.0.0/16"
  security_group_id = "${openstack_networking_secgroup_v2.ufr-only-v2.id}"
}

resource "openstack_networking_secgroup_rule_v2" "f01c6f64-3315-4ef1-8911-cf77f14ff07b" {
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_ip_prefix  = "10.0.0.0/8"
  security_group_id = "${openstack_networking_secgroup_v2.ufr-only-v2.id}"
}

resource "openstack_networking_secgroup_rule_v2" "0f66ecb7-4fe5-4a46-93ef-bef29ad75879" {
  direction         = "ingress"
  ethertype         = "IPv4"
  security_group_id = "${openstack_networking_secgroup_v2.ufr-only-v2.id}"
}

resource "openstack_networking_secgroup_rule_v2" "225accee-6cb6-48c5-9556-d60b19b2750f" {
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_ip_prefix  = "192.52.2.0/24"
  security_group_id = "${openstack_networking_secgroup_v2.ufr-only-v2.id}"
}

resource "openstack_networking_secgroup_rule_v2" "717d8793-cfe6-4769-953f-278c49daf158" {
  direction         = "ingress"
  ethertype         = "IPv4"
  security_group_id = "${openstack_networking_secgroup_v2.ufr-only-v2.id}"
}
