data "openstack_images_image_v2" "vgcn-image" {
  //name = "${var.image["name"]}"
  most_recent = true
}
data "openstack_images_image_v2" "vgcn-image-gpu" {
  //name = "${var.image["name"]}"
  most_recent = true
}