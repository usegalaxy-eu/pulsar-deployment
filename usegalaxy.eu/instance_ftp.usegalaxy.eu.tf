resource "openstack_compute_instance_v2" "ftp" {
  name            = "ftp.usegalaxy.eu"
  image_name      = "CentOS Server 7 RAW"
  flavor_name     = "m1.small"
  key_pair        = "cloud2"
  security_groups = ["egress", "Public"]

  network {
    name = "galaxy-net"
  }

  network {
    name = "public2"
  }
}
