#resource "openstack_networking_floatingip_v2" "floatip_1" {
#pool = "galaxy-net"
#}

resource "openstack_networking_router_v2" "router_1" {
  name           = "router_1"
  admin_state_up = "true"
}

resource "openstack_networking_network_v2" "network_1" {
  name           = "network_1"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subnet_1" {
  network_id = "${openstack_networking_network_v2.network_1.id}"
  cidr       = "192.168.199.0/24"
  ip_version = 4
}

resource "openstack_compute_secgroup_v2" "secgroup_1" {
  name        = "secgroup_1"
  description = "a security group"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_networking_router_interface_v2" "int_1" {
  router_id = "${openstack_networking_router_v2.router_1.id}"
  subnet_id = "${openstack_networking_subnet_v2.subnet_1.id}"
}

resource "openstack_networking_router_interface_v2" "int_2" {
  router_id = "${openstack_networking_router_v2.router_1.id}"
  subnet_id = "79651674-2158-4fb7-b6af-6513913b4b04"
}

#resource "openstack_networking_router_route_v2" "router_route_1" {
#  depends_on       = ["openstack_networking_router_interface_v2.int_1"]
#  router_id        = "${openstack_networking_router_v2.router_1.id}"
#  destination_cidr = "10.0.1.0/24"
#  next_hop         = "192.168.199.254"
#}

resource "openstack_networking_port_v2" "port_1" {
  name               = "port_1"
  network_id         = "${openstack_networking_network_v2.network_1.id}"
  admin_state_up     = "true"
  security_group_ids = ["${openstack_compute_secgroup_v2.secgroup_1.id}"]

  fixed_ip {
    "subnet_id"  = "${openstack_networking_subnet_v2.subnet_1.id}"
    "ip_address" = "192.168.199.10"
  }
}

resource "openstack_compute_instance_v2" "instance_1" {
  name            = "aaaaaaaaaaaaaa-cm"
  flavor_name     = "m1.medium"
  image_name      = "vggp-v29-j31-2ceb08399fa7-passordless"
  key_pair        = "cloud2"
  security_groups = ["${openstack_compute_secgroup_v2.secgroup_1.name}", "ingress-public", "egress"]

  network {
    port = "${openstack_networking_port_v2.port_1.id}"
  }

  user_data = <<-EOF
    #cloud-config
    users:
      - name: hxr
        gecos: Test User
        sudo: ALL=(ALL) NOPASSWD:ALL
        lock_passwd: false
        passwd: $6$yGzi5JMXyXUX0xRj$Q74.gsb7Qemy0Xsxs8scLkVuhTA30Wln9jhfDTtE7RLI0boYTWPdIxt6Pge59aS0kfPSTBcxLzrw8NxYKEY/J.
  EOF
}

resource "openstack_compute_instance_v2" "instance_2" {
  name            = "aaaaaaaaaaaaaa-exec-${count.index}"
  count           = 3
  flavor_name     = "m1.tiny"
  image_name      = "vggp-v29-j31-2ceb08399fa7-passordless"
  key_pair        = "cloud2"
  security_groups = ["ingress-public", "egress"]

  network {
    name = "${openstack_networking_network_v2.network_1.name}"
  }

  user_data = <<-EOF
    #cloud-config
    users:
      - name: hxr
        gecos: Test User
        sudo: ALL=(ALL) NOPASSWD:ALL
        lock_passwd: false
        passwd: $6$yGzi5JMXyXUX0xRj$Q74.gsb7Qemy0Xsxs8scLkVuhTA30Wln9jhfDTtE7RLI0boYTWPdIxt6Pge59aS0kfPSTBcxLzrw8NxYKEY/J.
  EOF
}
