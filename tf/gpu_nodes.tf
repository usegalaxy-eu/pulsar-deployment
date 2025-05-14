resource "oci_core_instance" "gpu-node" {

  count               = var.gpu_node_count
  availability_domain = var.oracle_vars.availability_domain
  compartment_id      = var.oracle_vars.compartment_id
  display_name        = "${var.name_prefix}gpu-node-${count.index}${var.name_suffix}"
  shape               = var.shapes["gpu-node"]

 shape_config {
    ocpus = var.shapes["gpu-node"].ocpus
    memory_in_gbs = var.shapes["gpu-node"].memory_in_gbs
  }
  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.vgcn_image_gpu.images[0].id
    
  }


  create_vnic_details {
    subnet_id        = oci_core_subnet.private_subnet.id
    assign_public_ip = false
  }
  
  metadata = {
  ssh_authorized_keys = local.ssh_public_key
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
        # Advertise the GPUs
        use feature : GPUs
        GPU_DISCOVERY_EXTRA = -extra
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
        share  -rw,hard,intr,nosuid,quota  ${oci_core_instance.nfs-server.private_ip}:/data/share
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
                condor_host: ${oci_core_instance.central-manager.private_ip}
                condor_password: ${var.condor_pass}

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
}

