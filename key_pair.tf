resource "openstack_compute_keypair_v2" "my-cloud-key" {
  name       = "cloud-key"
  public_key = "${var.public_key}"
}