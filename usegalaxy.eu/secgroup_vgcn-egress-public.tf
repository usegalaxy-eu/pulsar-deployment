resource "openstack_networking_secgroup_v2" "vgcn-egress-public" {
  name        = "vgcn-egress-public"
  description = "Allow any outgoing connection"
}

resource "openstack_networking_secgroup_rule_v2" "8e314a85-7128-441a-90cb-eda3bac5ea1e" {
  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = "${openstack_networking_secgroup_v2.vgcn-egress-public.id}"
}

resource "openstack_networking_secgroup_rule_v2" "05417db9-0d12-4453-acdc-08512350f1c3" {
  direction         = "egress"
  ethertype         = "IPv6"
  security_group_id = "${openstack_networking_secgroup_v2.vgcn-egress-public.id}"
}
