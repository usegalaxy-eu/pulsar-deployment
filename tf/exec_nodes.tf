resource "openstack_compute_instance_v2" "exec-node" {

  count           = "${var.exec_node_count}"
  name            = "${var.name_prefix}exec-node-${count.index}${var.name_suffix}"
  flavor_name     = "${var.flavors["exec-node"]}"
  image_id        = "${data.openstack_images_image_v2.vgcn-image.id}"
  key_pair        = "${openstack_compute_keypair_v2.my-cloud-key.name}"
  security_groups = "${var.secgroups}"


  network {
    uuid = "${data.openstack_networking_network_v2.internal.id}"
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
        ALLOW_ADMINISTRATOR = *
        ALLOW_NEGOTIATOR = $(ALLOW_ADMINISTRATOR)
        ALLOW_CONFIG = $(ALLOW_ADMINISTRATOR)
        ALLOW_DAEMON = $(ALLOW_ADMINISTRATOR)
        ALLOW_OWNER = $(ALLOW_ADMINISTRATOR)
        ALLOW_CLIENT = *
        DAEMON_LIST = MASTER, SCHEDD, STARTD
        FILESYSTEM_DOMAIN = vgcn
        UID_DOMAIN = vgcn
        TRUST_UID_DOMAIN = True
        SOFT_UID_DOMAIN = True
        # run with partitionable slots
        CLAIM_PARTITIONABLE_LEFTOVERS = True
        NUM_SLOTS = 1
        NUM_SLOTS_TYPE_1 = 1
        SLOT_TYPE_1 = 100%
        SLOT_TYPE_1_PARTITIONABLE = True
        ALLOW_PSLOT_PREEMPTION = False
        STARTD.PROPORTIONAL_SWAP_ASSIGNMENT = True
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
        ---
        - name: Install HTCondor Central Manager on Pulsar
          become: yes
          hosts: all
          connection: local
          roles:
            - name: usegalaxy_eu.htcondor
              vars:
                condor_role: execute
                condor_copy_template: false
                condor_host: ${openstack_compute_instance_v2.central-manager.network.1.fixed_ip_v4}
                condor_password: ${var.condor_pass}
          tasks:
            - name: Disable pulsar
              systemd:
                name: pulsar
                state: stopped 

      owner: centos:centos
      path: /home/centos/condor.yml
      permissions: '0644'
    packages: 
      - ansible
    runcmd:
      - [ sh, -xc, "sed -i 's|nameserver 10.0.2.3||g' /etc/resolv.conf" ]
      - [ sh, -xc, "sed -i 's|localhost.localdomain|$(hostname -f)|g' /etc/telegraf/telegraf.conf" ]
      - systemctl restart telegraf
      - [ python3, -m, pip, install, ansible ]
      - [ ansible-galaxy, install, -p, /home/centos/roles, usegalaxy_eu.htcondor ]
      - [ ansible-playbook, -i, 'localhost,', /home/centos/condor.yml]
      - systemctl start condor
      EOF
}
