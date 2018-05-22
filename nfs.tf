resource "openstack_compute_instance_v2" "nfs-server" {
  name            = "${var.name_prefix}nfs${var.name_suffix}"
  flavor_name     = "m1.medium"
  image_name      = "${var.image}"
  key_pair        = "${var.key_pair}"
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
