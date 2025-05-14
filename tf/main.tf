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

  }

  metadata = {
  ssh_authorized_keys = local.ssh_public_key
  user_data = base64encode(<<EOF
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
        share  -rw,hard,intr,nosuid,quota  ${oci_core_instance.nfs_server.private_ip}:/data/share
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
      - [ firewall-cmd, --permanent, --add-port=2049/tcp ]
      - [ firewall-cmd, --reload ]
      - [ automount ]
      - [ sh, -xc, "sed -i 's|nameserver 10.0.2.3||g' /etc/resolv.conf" ]
      - [ sh, -xc, "sed -i 's|localhost.localdomain|$(hostname -f)|g' /etc/telegraf/telegraf.conf" ]
      - systemctl restart telegraf
  EOF
  )
}
}

resource "oci_core_vnic_attachment" "manager_private_vnic" {
  instance_id = oci_core_instance.central_manager.id
  display_name = "manager-internal"

  create_vnic_details {
    assign_public_ip = false
    subnet_id        = oci_core_subnet.private_subnet.id
  }

  lifecycle {
    replace_triggered_by = [
      oci_core_instance.central_manager
    ]
  }

}

resource "null_resource" "provision_central_manager" {
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