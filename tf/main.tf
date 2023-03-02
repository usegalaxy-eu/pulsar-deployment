resource "openstack_compute_instance_v2" "central-manager" {

  name            = "${var.name_prefix}central-manager${var.name_suffix}"
  flavor_name     = "${var.flavors["central-manager"]}"
  image_id        = "${data.openstack_images_image_v2.vgcn-image.id}"
  key_pair        = "${openstack_compute_keypair_v2.my-cloud-key.name}"
  security_groups = "${var.secgroups_cm}"

  network {
    uuid = "${data.openstack_networking_network_v2.external.id}"
  }
  network {
    uuid = "${data.openstack_networking_network_v2.internal.id}"
  }

 // provisioner "remote-exec" {
 //   inline = ["sudo dnf update -y", "echo Done!"]

 //   connection {
 //     host        = self.access_ip_v4
 //     type        = "ssh"
 //     user        = "centos"
 //     private_key = file(var.pvt_key)
 //   }
 // }
  
  provisioner "local-exec" {
    command = "sleep 60; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u centos -b -i '${self.access_ip_v4},' --private-key ${var.pvt_key} --extra-vars='condor_ip_range=${var.private_network.cidr4} condor_host=${self.network.1.fixed_ip_v4} condor_ip_range=${var.private_network.cidr4} condor_password=${var.condor_pass}' condor-install-cm.yml"
  }

  user_data = <<-EOF
    #cloud-config
    system_info:
      default_user:
        name: centos
        gecos: RHEL Cloud User
        groups: [wheel, adm, systemd-journal]
        sudo: ["ALL=(ALL) NOPASSWD:ALL"]
        shell: /bin/bash
      distro: rhel
      paths:
        cloud_dir: /var/lib/cloud
        templates_dir: /etc/cloud/templates
      ssh_svcname: sshd
    write_files:
    - content: |
        ALLOW_WRITE = *
        ALLOW_READ = $(ALLOW_WRITE)
        ALLOW_NEGOTIATOR = $(ALLOW_WRITE)
        DAEMON_LIST = COLLECTOR, MASTER, NEGOTIATOR, SCHEDD
        FILESYSTEM_DOMAIN = vgcn
        UID_DOMAIN = vgcn
        TRUST_UID_DOMAIN = True
        SOFT_UID_DOMAIN = True
      owner: root:root
      path: /etc/condor/condor_config.local
      permissions: '0644'
    - content: |
        /data           /etc/auto.data          nfsvers=3
      owner: root:root
      path: /etc/auto.master.d/data.autofs
      permissions: '0644'
    - content: |
        share  -rw,hard,intr,nosuid,quota  ${openstack_compute_instance_v2.nfs-server.access_ip_v4}:/data/share
      owner: root:root
      path: /etc/auto.data
      permissions: '0644'
    - content: |
        Host *
            GSSAPIAuthentication yes
        	ForwardX11Trusted yes
        	SendEnv LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES
            SendEnv LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT
            SendEnv LC_IDENTIFICATION LC_ALL LANGUAGE
            SendEnv XMODIFIERS
            StrictHostKeyChecking no
            UserKnownHostsFile=/dev/null
      owner: root:root
      path: /etc.intra-vgcn-key.ssh_config
      permissions: '0644'

    runcmd:
      - [ sh, -xc, "sed -i 's|nameserver 10.0.2.3||g' /etc/resolv.conf" ]
      - [ sh, -xc, "sed -i 's|localhost.localdomain|$(hostname -f)|g' /etc/telegraf/telegraf.conf" ]
      - systemctl restart telegraf
      - [mv, /etc.intra-vgcn-key.vgcn.key, /home/centos/.ssh/id_rsa]
      - chmod 0600 /home/centos/.intra-vgcn-key.id_rsa
      - [chown, centos.centos, /home/centos/.intra-vgcn-key.id_rsa]
  EOF
}
