resource "openstack_compute_instance_v2" "temp" {
  name            = "genomics-dc-image-build"
  flavor_name     = "m1.medium"
  image_name      = "Ubuntu Server 16.04 RAW"
  key_pair        = "${var.key_pair}"
  security_groups = "${var.secgroups}"
  network         = "${var.network}"
}
