# Create a block volume for NFS data
resource "oci_core_volume" "volume_nfs_data" {
  availability_domain = var.oracle_vars.availability_domain
  compartment_id      = var.oracle_vars.compartment_id
  display_name        = "${var.name_prefix}volume_nfs_data"
  size_in_gbs         = var.nfs_disk_size
}

# Create volume attachment to connect the block volume to the instance
resource "oci_core_volume_attachment" "nfs_data_attachment" {
  attachment_type = "iscsi"  # Or "paravirtualized"
  instance_id     = oci_core_instance.nfs_server.id
  volume_id       = oci_core_volume.volume_nfs_data.id
  
  depends_on      = [oci_core_instance.nfs_server]
}

# Cloud-init template to configure NFS
data "template_cloudinit_config" "nfs_share" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = file("${path.module}/files/create_share.sh")
  }

  part {
    content_type = "text/cloud-config"
    content      = <<-EOF
    #cloud-config
    write_files:
    - content: |
        /data/share *(rw,sync)
      owner: root:root
      path: /etc/exports
      permissions: '0644'

    runcmd:
     - [ sh, -xc, "sed -i 's|nameserver 10.0.2.3||g' /etc/resolv.conf" ]
     - [ firewall-cmd, --permanent, --add-port=2049/tcp ]
     - [ firewall-cmd, --reload ]
     - [ systemctl, enable, nfs-server ]
     - [ systemctl, start, nfs-server ]
     - [ exportfs, -avr ]
    EOF
  }
}

# Create the NFS server instance
resource "oci_core_instance" "nfs_server" {
  availability_domain = var.oracle_vars.availability_domain
  compartment_id      = var.oracle_vars.compartment_id
  display_name        = "${var.name_prefix}nfs${var.name_suffix}"
  
  shape               = var.shapes["nfs-server"]
  
 
 shape_config {
    ocpus = var.shapes["nfs-server"].ocpus
    memory_in_gbs = var.shapes["nfs-server"].memory_in_gbs
  }
  
  # Reference the image using the OCID
  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.vgcn_image.images[0].id
    
  }
  
  # Networt
  create_vnic_details {
    subnet_id        = oci_core_subnet.internal.id
    assign_public_ip = false
    nsg_ids          = [oci_core_network_security_group.ingress_private.id, oci_core_network_security_group.egress_public]
  }
  
  # SSH key configuration
  metadata = {
    ssh_authorized_keys = local.ssh_public_key
    user_data           = data.template_cloudinit_config.nfs_share.rendered
  }
  
  # Wait for the networking resources to be created
  depends_on = [
    oci_core_subnet.internal
  ]
  
  preserve_boot_volume = false
}
