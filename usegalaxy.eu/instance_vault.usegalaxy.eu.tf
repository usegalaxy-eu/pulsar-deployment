resource "openstack_compute_instance_v2" "vault-server" {
  name            = "vault.usegalaxy.eu"
  image_name      = "CentOS 7"
  flavor_name     = "m1.tiny"
  key_pair        = "cloud2"
  security_groups = ["public-web", "public-ping", "egress", "ufr-ssh"]

  network {
    name = "public"
  }
}
