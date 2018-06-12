resource "openstack_compute_instance_v2" "proxy" {
  name            = "proxy.usegalaxy.eu"
  image_name      = "CentOS Server 7 RAW"
  flavor_name     = "m1.small"
  key_pair        = "cloud2"
  security_groups = ["public-web", "public-ping", "egress", "public-ssh"]

  network {
    name = "public2"
  }
}