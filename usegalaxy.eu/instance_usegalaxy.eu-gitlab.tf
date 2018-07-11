resource "openstack_compute_instance_v2" "gitlab" {
  name            = "usegalaxy.eu-gitlab"
  image_name      = "CentOS 7"
  flavor_name     = "m1.large"
  key_pair        = "tower"
  security_groups = ["public-irc", "public-web", "public-ping", "egress", "public-ssh"]

  network {
    name = "public"
  }
}
