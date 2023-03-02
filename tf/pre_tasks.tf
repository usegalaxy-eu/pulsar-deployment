// Upload virtual machine image via API
// comment this block if the image is already available or if you upload it via the dashboard interface
resource "openstack_images_image_v2" "_vgcn-image" {
  name   = "${var.image["name"]}"
  image_source_url = "${var.image["image_source_url"]}"
  container_format = "${var.image["container_format"]}"
  disk_format = "${var.image["disk_format"]}"
}

// Create private network
// comment these blocks if the network is already available
//resource "openstack_networking_network_v2" "_internal" {
//  name           = "${var.private_network["name"]}"
//  admin_state_up = "true"
//}
//
//resource "openstack_networking_subnet_v2" "_internal" {
//  name        = "${var.private_network["subnet_name"]}"
//  network_id  = "${openstack_networking_network_v2._internal.id}"
//  cidr       = "${var.private_network["cidr4"]}"
//  ip_version  = 4
//  enable_dhcp = true
//}

// Create a router to ensure the private network will be able to reach the Internet
// comment these blocks if this feature is provided by the network
//resource "openstack_networking_router_v2" "router_1" {
//  name                = "${var.name_prefix}router"
//  external_network_id = "${data.openstack_networking_network_v2.external.id}"
//}
//
//resource "openstack_networking_router_interface_v2" "router_interface_1" {
//  router_id = "${openstack_networking_router_v2.router_1.id}"
//  subnet_id = "${openstack_networking_subnet_v2._internal.id}"
//}
