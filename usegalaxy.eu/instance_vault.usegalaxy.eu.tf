resource "openstack_compute_instance_v2" "vault-server" {
  name            = "vault.usegalaxy.eu"
  image_id        = "0bd53c04-118c-43c7-bdff-c417eea0556a"
  flavor_name     = "m1.tiny"
  key_pair        = "cloud2"
  security_groups = ["ingress-public", "egress-public"]

  network {
    name = "public2"
  }
}
