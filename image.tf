resource "openstack_images_image_v2" "vggp" {
  name             = "x_${var.image}"
  image_source_url = "https://usegalaxy.eu/static/vgcn/${var.image}.raw"
  container_format = "bare"
  disk_format      = "raw"

  properties {
    key = "value"
  }
}
