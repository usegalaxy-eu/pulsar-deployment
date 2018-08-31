resource "openstack_compute_instance_v2" "debian" {
  name            = "debian-test"
  image_name      = "Ubuntu 18.04"
  flavor_name     = "m1.xlarge"
  key_pair        = "cloud2"
  security_groups = ["egress", "ufr-ssh"]
  count           = 1

  network {
    name = "public"
  }
}
