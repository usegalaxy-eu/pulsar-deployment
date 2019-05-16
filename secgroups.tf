resource "openstack_networking_secgroup_v2" "ingress-public" {
  name                 = "${var.name_prefix}ingress-public"
  description          = "Allow any incoming connection"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_rule_v2" "ingress-public-4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  security_group_id = "${openstack_networking_secgroup_v2.ingress-public.id}"
}

resource "openstack_networking_secgroup_rule_v2" "ingress-public-6" {
  direction         = "ingress"
  ethertype         = "IPv6"
  security_group_id = "${openstack_networking_secgroup_v2.ingress-public.id}"
}

resource "openstack_networking_secgroup_v2" "egress-public" {
  name                 = "${var.name_prefix}egress-public"
  description          = "Allow any outgoing connection"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_rule_v2" "egress-public-4" {
  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = "${openstack_networking_secgroup_v2.egress-public.id}"
}

resource "openstack_networking_secgroup_rule_v2" "egress-public-6" {
  direction         = "egress"
  ethertype         = "IPv6"
  security_group_id = "${openstack_networking_secgroup_v2.egress-public.id}"
}
