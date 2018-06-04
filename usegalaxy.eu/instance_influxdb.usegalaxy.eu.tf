resource "openstack_compute_instance_v2" "build" {
  name            = "build.usegalaxy.eu"
  image_name      = "ubuntu-16.04-multinic"
  flavor_name     = "m1.small"
  key_pair        = "cloud2"
  security_groups = ["public-web", "public-ping", "egress", "ufr-ssh"]

  network {
    name = "public2"
  }
}
