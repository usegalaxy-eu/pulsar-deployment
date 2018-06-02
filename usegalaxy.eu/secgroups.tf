resource "openstack_networking_secgroup_v2" "ingress-public" {
  name        = "ingress-public"
  description = "Allow any incoming connection"
}

resource "openstack_networking_secgroup_v2" "default" {
  name        = "default"
  description = "Default security group"
}

resource "openstack_networking_secgroup_v2" "public-irc" {
  name        = "public-irc"
  description = ""
}

resource "openstack_networking_secgroup_v2" "public-influxdb" {
  name        = "public-influxdb"
  description = "Allow public HTTP(s) connections to port 8086"
}

resource "openstack_networking_secgroup_v2" "ufr-ssh" {
  name        = "ufr-ssh"
  description = "Ingress SSH connections for UFR networks (e.g. combine with public-web/public-ping)"
}

resource "openstack_networking_secgroup_v2" "public-web" {
  name        = "public-web"
  description = "Allow public HTTP + HTTPS connections"
}

resource "openstack_networking_secgroup_v2" "public-mosh" {
  name        = "public-mosh"
  description = "public-mosh"
}

resource "openstack_networking_secgroup_v2" "vgcn-ingress-public" {
  name        = "vgcn-ingress-public"
  description = "Allow any incoming connection"
}

resource "openstack_networking_secgroup_v2" "vgcn-egress-public" {
  name        = "vgcn-egress-public"
  description = "Allow any outgoing connection"
}

resource "openstack_networking_secgroup_v2" "egress-public" {
  name        = "egress-public"
  description = "Allow any outgoing connection"
}

resource "openstack_networking_secgroup_v2" "public-ping" {
  name        = "public-ping"
  description = "Allow pinging the node to the public"
}

resource "openstack_networking_secgroup_v2" "Gilsbach_webserver" {
  name        = "Gilsbach webserver"
  description = "Open port 8080 and 8081."
}

resource "openstack_networking_secgroup_v2" "egress" {
  name        = "egress"
  description = "Default egress profile"
}

resource "openstack_networking_secgroup_v2" "secgroup_1" {
  name        = "secgroup_1"
  description = "a security group"
}

resource "openstack_networking_secgroup_v2" "Public" {
  name        = "Public"
  description = ""
}

resource "openstack_networking_secgroup_v2" "ufr-ingress" {
  name        = "ufr-ingress"
  description = "Ingress connections from any UFR networks"
}

resource "openstack_networking_secgroup_v2" "public-ssh" {
  name        = "public-ssh"
  description = "Allow SSH connections from anywhere"
}

resource "openstack_networking_secgroup_v2" "ufr-only-v2" {
  name        = "ufr-only-v2"
  description = "New ingress connections allowed only from UFR networks"
}
