// Since th available format of the VGCN cannot be used in Oracle
// images are to be processed and uploaded manually for the time being

data "oci_core_images" "vgcn_image" {
  compartment_id           = var.oracle_vars.compartment_id
  display_name             = var.image.name

}

// Upload virtual machine GPU image via API
// comment this block if the GPU image is already available or if you upload it via the dashboard interface
data "oci_core_images" "vgcn_image_gpu" {
  compartment_id           = var.oracle_vars.compartment_id
  display_name             = var.gpu_image.name

}
