resource "openstack_compute_keypair_v2" "my-cloud-key" {
  name       = "${var.name_prefix}cloud_key"
  public_key = "${var.public_key}"
}