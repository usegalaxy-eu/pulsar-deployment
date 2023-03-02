//resource "openstack_networking_secgroup_v2" "ingress-private" {
//  name                 = "${var.secgroups_cm[1]}"
//  description          = "[tf] Allow any incoming connection from private network"
//  delete_default_rules = true
//}
//
//resource "openstack_networking_secgroup_rule_v2" "ingress-private-4" {
//  direction         = "ingress"
//  ethertype         = "IPv4"
//  remote_ip_prefix  = "${var.private_network["cidr4"]}"
//  security_group_id = "${openstack_networking_secgroup_v2.ingress-private.id}"
//}
//
////resource "openstack_networking_secgroup_rule_v2" "ingress-private-6" {
////  direction         = "ingress"
////  ethertype         = "IPv6"
////  security_group_id = "${openstack_networking_secgroup_v2.ingress-private.id}"
////}
//
//resource "openstack_networking_secgroup_v2" "egress-public" {
//  name                 = "${var.secgroups_cm[2]}"
//  description          = "[tf] Allow any outgoing connection"
//  delete_default_rules = true
//}
//
//resource "openstack_networking_secgroup_rule_v2" "egress-public-4" {
//  direction         = "egress"
//  ethertype         = "IPv4"
//  security_group_id = "${openstack_networking_secgroup_v2.egress-public.id}"
//}
//
//resource "openstack_networking_secgroup_rule_v2" "egress-public-6" {
//  direction         = "egress"
//  ethertype         = "IPv6"
//  security_group_id = "${openstack_networking_secgroup_v2.egress-public.id}"
//}
//
//resource "openstack_networking_secgroup_v2" "public-ssh" {
//  name                 = "${var.secgroups_cm[0]}"
//  description          = "[tf] Allow SSH connections from anywhere"
//  delete_default_rules = "true"
//}
//
//resource "openstack_networking_secgroup_rule_v2" "public-ssh-4" {
//  direction         = "ingress"
//  ethertype         = "IPv4"
//  protocol          = "tcp"
//  port_range_min    = "${var.ssh-port}"
//  port_range_max    = "${var.ssh-port}"
//  security_group_id = "${openstack_networking_secgroup_v2.public-ssh.id}"
//}
//
//resource "openstack_networking_secgroup_rule_v2" "publich-ssh-6" {
//  direction = "ingress"
//  ethertype = "IPv6"
//  protocol = "tcp"
//  port_range_min = "${var.ssh-port}"
//  port_range_max = "${var.ssh-port}"
//  security_group_id = "${openstack_networking_secgroup_v2.public-ssh.id}"
//}