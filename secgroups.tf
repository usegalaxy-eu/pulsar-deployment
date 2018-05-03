# resource "openstack_networking_secgroup_v2" "public-web" {
#   name        = "public-web"
#   description = "Public HTTP(S) access"
# }
# 
# resource "openstack_networking_secgroup_rule_v2" "public-web-80" {
#   direction         = "ingress"
#   ethertype         = "IPv4"
#   protocol          = "tcp"
#   port_range_min    = 80
#   port_range_max    = 80
#   remote_ip_prefix  = "0.0.0.0/0"
#   security_group_id = "${openstack_networking_secgroup_v2.public-web.id}"
# }
# 
# resource "openstack_networking_secgroup_rule_v2" "public-web-443" {
#   direction         = "ingress"
#   ethertype         = "IPv4"
#   protocol          = "tcp"
#   port_range_min    = 443
#   port_range_max    = 443
#   remote_ip_prefix  = "0.0.0.0/0"
#   security_group_id = "${openstack_networking_secgroup_v2.public-web.id}"
# }
# 
# 
# resource "openstack_networking_secgroup_v2" "public-ssh" {
#   name        = "public-ssh"
#   description = "Public SSH access"
# }
# 
# resource "openstack_networking_secgroup_rule_v2" "public-ssh-22" {
#   direction         = "ingress"
#   ethertype         = "IPv4"
#   protocol          = "tcp"
#   port_range_min    = 22
#   port_range_max    = 22
#   remote_ip_prefix  = "0.0.0.0/0"
#   security_group_id = "${openstack_networking_secgroup_v2.public-ssh.id}"
# }

resource "openstack_networking_secgroup_v2" "public-condor" {
  name        = "public-condor"
  description = "Public HTCondor Access"
}

resource "openstack_networking_secgroup_rule_v2" "public-condor-collector" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 9618
  port_range_max    = 9618
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.public-condor.id}"
}

resource "openstack_networking_secgroup_rule_v2" "public-condor-dynamic" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 12000
  port_range_max    = 18000
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.public-condor.id}"
}

resource "openstack_networking_secgroup_rule_v2" "public-condor-WTF" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.public-condor.id}"
}
