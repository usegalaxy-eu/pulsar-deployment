resource "openstack_compute_instance_v2" "nfs-server" {
  name            = "${var.name_prefix}nfs${var.name_suffix}"
  flavor_name     = "${var.flavors[1]}"
  image_name      = "${var.image}"
  key_pair        = "${openstack_compute_keypair_v2.my-cloud-key.name}"
  security_groups = "${var.secgroups}"
  network         = "${var.network}"

  user_data = <<-EOF
    #cloud-config
    write_files:
    - content: |
        /data/share *(rw,sync)
      owner: root:root
      path: /etc/exports
      permissions: '0644'

    runcmd:
     - [ mkdir, -p, /data/share ]
     - [ chown, galaxy:galaxy, -R, /data/share ]
     - [ systemctl, enable, nfs-server ]
     - [ systemctl, start, nfs-server ]
     - [ exportfs, -avr ]
  EOF
}
