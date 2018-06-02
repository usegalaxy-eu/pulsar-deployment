resource "openstack_networking_secgroup_v2" "public-ssh" {
  name        = "public-ssh"
  description = "Allow SSH connections from anywhere"
}

resource "openstack_networking_secgroup_rule_v2" "aa57e62d-6644-40fb-ad6f-05b50e14bb54" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  port_range_min    = "22"
  port_range_max    = "22"
  security_group_id = "${openstack_networking_secgroup_v2.public-ssh.id}"
}
