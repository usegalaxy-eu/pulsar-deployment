resource "openstack_networking_secgroup_v2" "egress-public" {
  name        = "egress-public"
  description = "Allow any outgoing connection"
}

resource "openstack_networking_secgroup_rule_v2" "8187fcad-1b68-464a-930f-9e2bec65af25" {
  direction         = "ingress"
  ethertype         = "IPv4"
  security_group_id = "${openstack_networking_secgroup_v2.egress-public.id}"
}

resource "openstack_networking_secgroup_rule_v2" "948d57bc-6b77-4d6b-96c1-0ed1564c1aaf" {
  direction         = "ingress"
  ethertype         = "IPv6"
  security_group_id = "${openstack_networking_secgroup_v2.egress-public.id}"
}
