locals {
  exec_user_data = templatefile(
    "${path.module}/cloud_init_templates/exec_cloud_init.yaml.tftpl",
    {
      nfs_ip = oci_core_instance.nfs_server.private_ip
      cm_ip       = oci_core_instance.central_manager.private_ip
      condor_pass = var.condor_pass
    }
  )
}

resource "oci_core_instance" "exec-node" {

  count               = var.exec_node_count
  availability_domain = var.oracle_vars.availability_domain
  compartment_id      = var.oracle_vars.compartment_id
  display_name        = "${var.name_prefix}exec-node-${count.index}${var.name_suffix}"
  shape               = var.shapes["exec-node"].shape

  # Reference the image using the OCID
 shape_config {
    ocpus = var.shapes["exec-node"].ocpus
    memory_in_gbs = var.shapes["exec-node"].memory_in_gbs
  }

 launch_options {
    network_type     = "PARAVIRTUALIZED"
    boot_volume_type = "PARAVIRTUALIZED"
    }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.vgcn_image.images[0].id
    
  }
  create_vnic_details {
    subnet_id        = oci_core_subnet.private_subnet.id
    assign_public_ip = false
    nsg_ids          = [ 
                       oci_core_network_security_group.ingress_private.id, 
                       oci_core_network_security_group.egress_public.id
                       ] 
  }

  metadata = {
  ssh_authorized_keys = local.ssh_public_key
  user_data = base64encode(local.exec_user_data)
}
}
