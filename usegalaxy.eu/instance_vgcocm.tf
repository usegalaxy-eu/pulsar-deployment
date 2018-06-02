resource "openstack_compute_instance_v2" "vgcocm" {
  name            = "vgcocm"
  image_name      = "vgcocmbwc7-15a"
  flavor_name     = "m1.xlarge2"
  key_pair        = "cloud2"
  security_groups = ["ufr-only-v2"]

  network {
    name = "galaxy-net"
  }
}
