locals {
  gpu_exec_user_data = templatefile(
    "${path.module}/cloud_init_templates/gpu_exec_cloud_init.yaml.tftpl",
    {
      nfs_ip = oci_core_instance.nfs_server.private_ip
      cm_ip       = oci_core_instance.central_manager.private_ip
      condor_pass = var.condor_pass
    }
  )
}

resource "oci_core_instance" "gpu-node" {

  count               = var.gpu_node_count
  availability_domain = var.oracle_vars.availability_domain
  compartment_id      = var.oracle_vars.compartment_id
  display_name        = "${var.name_prefix}gpu-node-${count.index}${var.name_suffix}"
  shape               = var.shapes["gpu-node"].shape

 shape_config {
    ocpus = var.shapes["gpu-node"].ocpus
    memory_in_gbs = var.shapes["gpu-node"].memory_in_gbs
  }
  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.vgcn_image_gpu.images[0].id
    
  }

 launch_options {
    network_type     = "PARAVIRTUALIZED"
    boot_volume_type = "PARAVIRTUALIZED"
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
  user_data = base64encode(local.gpu_exec_user_data)
}
}

