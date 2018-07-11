resource "openstack_compute_instance_v2" "ftp" {
  name            = "ftp.usegalaxy.eu"
  image_name      = "CentOS 7"
  flavor_name     = "m1.small"
  key_pair        = "cloud2"
  security_groups = ["egress", "public"]

  network {
    name = "public"
  }
}
