locals {
  cm_user_data = templatefile(
    "${path.module}/cloud_init_templates/cm_cloud_init.yaml.tftpl",
    {
      nfs_ip = oci_core_instance.nfs_server.private_ip
    }
  )
}

resource "oci_core_instance" "central_manager" {
  availability_domain = var.oracle_vars.availability_domain
  compartment_id      = var.oracle_vars.compartment_id
  display_name        = "${var.name_prefix}central-manager${var.name_suffix}"
  shape               = var.shapes["central-manager"].shape

  # Reference the image using the OCID
   shape_config {
    ocpus = var.shapes["central-manager"].ocpus
    memory_in_gbs = var.shapes["central-manager"].memory_in_gbs
  }
  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.vgcn_image.images[0].id
    
  }
  
 launch_options {
    network_type     = "PARAVIRTUALIZED" # Use VirtIO drivers, like openstack
    boot_volume_type = "PARAVIRTUALIZED"
    }

  create_vnic_details {
    subnet_id        = oci_core_subnet.public_subnet.id
    assign_public_ip = true
    nsg_ids          = [ 
                       oci_core_network_security_group.cm_egress_public.id,
                       oci_core_network_security_group.public_ssh.id
                       ] 
  }

  metadata = {
  ssh_authorized_keys = local.ssh_public_key
  user_data = base64encode(local.cm_user_data)
}
}

resource "oci_core_vnic_attachment" "manager_private_vnic" {
  instance_id = oci_core_instance.central_manager.id
  display_name = "manager-internal"

  create_vnic_details {
    assign_public_ip = false
    subnet_id        = oci_core_subnet.private_subnet.id
    nsg_ids          = [ 
                       oci_core_network_security_group.cm_ingress_private.id, 
                       oci_core_network_security_group.cm_egress_public.id
                       ] 
  }
  lifecycle {
    replace_triggered_by = [
      oci_core_instance.central_manager
    ]
  }

}

resource "null_resource" "provision_central_manager" {
  depends_on = [ oci_core_vnic_attachment.manager_private_vnic ]
  lifecycle {
    replace_triggered_by = [
      oci_core_instance.central_manager
    ]
  }
  provisioner "local-exec" {
    command = <<-EOF
      ansible-galaxy install -p ansible/roles -r ansible/requirements.yml
      sleep 450
        ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u centos -b -i '${oci_core_instance.central_manager.public_ip},' \
        --private-key ${var.pvt_key} --extra-vars='condor_ip_range=${oci_core_subnet.private_subnet.cidr_block}  
        htcondor_server=${oci_core_instance.central_manager.private_ip} htcondor_password=${var.condor_pass}
        message_queue_url="${var.mq_string}" tf_var_check=True' -e '${jsonencode(local.norm_ex_mqs)}' \
        ansible/main.yml
    EOF
  }

}