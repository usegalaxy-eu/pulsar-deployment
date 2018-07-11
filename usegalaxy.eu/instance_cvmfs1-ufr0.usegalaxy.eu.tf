resource "openstack_compute_instance_v2" "cvmfs1-ufr0" {
  name            = "cvmfs1-ufr0.usegalaxy.eu"
  image_name      = "CentOS 7"
  flavor_name     = "m1.small"
  key_pair        = "cloud2"
  security_groups = ["public-web", "public-ping", "egress", "public-ssh"]

  network {
    name = "public"
  }
}
