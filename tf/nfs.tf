resource "openstack_compute_instance_v2" "nfs-server" {

  name            = "${var.name_prefix}nfs${var.name_suffix}"
  image_id        = "${data.openstack_images_image_v2.vgcn-image.id}"
  flavor_name     = "${var.flavors["nfs-server"]}"
  key_pair        = "${openstack_compute_keypair_v2.my-cloud-key.name}"
  security_groups = "${var.secgroups}"

  network {
    uuid = "${data.openstack_networking_network_v2.internal.id}"
  }

  block_device {
    uuid                  = "${data.openstack_images_image_v2.vgcn-image.id}"
    source_type           = "image"
    destination_type      = "local"
    boot_index            = 0
    delete_on_termination = true
  }

  block_device {   
    uuid                  = "${openstack_blockstorage_volume_v2.volume_nfs_data.id}"
    source_type           = "volume"
    destination_type      = "volume"
    boot_index            = -1
    delete_on_termination = true
  }

  user_data = "${data.template_cloudinit_config.nfs-share.rendered}"
}


resource "openstack_blockstorage_volume_v2" "volume_nfs_data" {
  name = "${var.name_prefix}volume_nfs_data"
  size = "${var.nfs_disk_size}"
}

data "template_cloudinit_config" "nfs-share" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = "${file("${path.module}/files/create_share.sh")}"
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
     - [ systemctl, enable, nfs-server ]
     - [ systemctl, start, nfs-server ]
     - [ exportfs, -avr ]
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC49BanKDSkoT22TWvNeL+4x/qcRi0a7Nuf+GmDXEEaCWlhvD7oeYoqVm/Jbbxo0FSDENwpMds5nR8MrdInOL1Ycp9sOoOsi0Sf1mMKhErHE2O+SHmQrPiKphams3wNSllKV80171E+7+ljYcUPREybBomZgYWlqeh46q+41AEFWxn6MYlQud/pa7TTnu/1egaWhX5W+P3l9Mo+x13LOywqbTl+545gvKg2bAHdkFkj/k/YKqM/DSFXT4Cx2r/OWZuR6oBLvsjmsld6rUdDhgIKqxQgK523NJv2gm0TS2JBXzFLsnH+ByIF55r1VCQlhYqfbl0w1O6exbc7pUnRy+ch

  EOF
  }
}
