resource "openstack_images_image_v2" "vgcn-image" {
  name   = "${var.image["name"]}"
  image_source_url = "${var.image["image_source_url"]}"
  container_format = "${var.image["container_format"]}"
  disk_format = "${var.image["disk_format"]}"
}
