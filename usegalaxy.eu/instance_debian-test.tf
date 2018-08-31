resource "openstack_compute_instance_v2" "debian" {
  name            = "test"
  image_name      = "vggp-v30-j56-c5ccc6e703bf-asdf3"
  flavor_name     = "m1.xlarge"
  key_pair        = "cloud2"
  security_groups = ["egress", "ufr-ssh"]
  count           = 1

  network {
    name = "public"
  }
}
