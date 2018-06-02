resource "openstack_networking_secgroup_v2" "ingress-public" {
  name        = "ingress-public"
  description = "Allow any incoming connection"
}

resource "openstack_networking_secgroup_rule_v2" "a7cbadeb-926b-46cf-9cb5-83203f1765aa" {
  direction         = "ingress"
  ethertype         = "IPv4"
  security_group_id = "${openstack_networking_secgroup_v2.ingress-public.id}"
}

resource "openstack_networking_secgroup_rule_v2" "fb24ccbf-025a-494f-b632-62e107e12ae1" {
  direction         = "ingress"
  ethertype         = "IPv6"
  security_group_id = "${openstack_networking_secgroup_v2.ingress-public.id}"
}
