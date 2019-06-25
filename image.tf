data "openstack_images_image_v2" "vgcn-image" {
  name = "${var.image["name"]}"
}
