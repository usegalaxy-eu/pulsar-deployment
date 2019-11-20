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

  user_data = <<-EOF
    #cloud-config
    write_files:
    - content: |
        -----BEGIN RSA PRIVATE KEY-----
        MIIEpAIBAAKCAQEAuPQWpyg0pKE9tk1rzXi/uMf6nEYtGuzbn/hpg1xBGglpYbw+
        6HmKKlZvyW28aNBUgxDcKTHbOZ0fDK3SJzi9WHKfbDqDrItEn9ZjCoRKxxNjvkh5
        kKz4iqYWprN8DUpZSlfNNe9RPu/pY2HFD0RMmwaJmYGFpanoeOqvuNQBBVsZ+jGJ
        ULnf6Wu0057v9XoGloV+Vvj95fTKPsddyzssKm05fueOYLyoNmwB3ZBZI/5P2Cqj
        Pw0hV0+Asdq/zlmbkeqAS77I5rJXeq1HQ4YCCqsUICudtzSb9oJtE0tiQV8xS7Jx
        /gciBeea9VQkJYWKn25dMNTunsW3O6VJ0cvnIQIDAQABAoIBADvPKxgpB0UJo1Q1
        mxvZ5V3SxXcNtn5Tg/4qLay+A4tw6bQiVNGGpChmxUWFB/15CStNI3Tq23K5HZZT
        C3eFgK1+e5FbJsOAUdPCV0rKVwgjfAjHlRA07zae2QpVVlNR7Kf+1qyPVF2e5YEu
        17PFKWSka5DJcreMx1F6yxJg9GePbn+JziQ/iN5MVSL4jqSH+ozVp9DzRa92VZOE
        BM8CdbR2hX3d19AJoHjWcBJAEbo9/FzG6d/4nTHMXNW/sbcrIZbFwiyPex4eTBz5
        Uo+BJKt9w6H8n4PS611sW2n9B6N4+VcVpba8QxYccaOaqdyzQgV4NedCvhNYPe1n
        lENoxzECgYEA3/0NVstAL8vZMcWr5yE8xjJkLZPZmPepOksd0OgZQJ363aoUqw9G
        YzEFDepbAq/8oS278MqBbJJ0DN5sH54nPil+ge5AFufrH7hNY9B4Q64hEqcOOXBH
        hLG1dVxZmqZc3XTmI1OTF6i6Q99zx2t591hTskAbzhnJAevGfLbDI20CgYEA02Li
        Ddj13QdqiSakul80uPJHW6BbXHEzNav2qWT4rBWFjbPnOLiwEEz8cw3LJb64s/Wc
        lD70kOA8EYKEe+QiXM4aQKdHyTRn7qau5M3uWNNxrRz4N5b4smzfIAHtqkU/5hWZ
        blh7e8w0gZ3dArTKCReOfkCxhmWHRLk+0yhVTgUCgYBJ+vzC5BLpNn0gUVe72WCH
        XfF0lFbUjUhZtqG8dEyS6RsIx7pX3Y20CWbP983jj1jzq3VdzKT+xUiLT5OKxePU
        RkRAif6lEii4q1j0VNDEGelWjdLG6ezVSRTUFJKL39LgWlIA7QOyVspezJkjDr6U
        EZpjT4Vfh2i6t7MxUfQV6QKBgQDIb5SlSLoosOWF0syTo77cN28OJIk8qGHEXKBw
        krtwgJ+4c4OltwnLCxS9C7E6wxNkIFot/1vrG5QZjkaNKw6iLRObhoJ8+GIsWoSv
        k8yTETtSyItcOpzqom0Xbnyq3Srvwj9P8Dp2cnS/Cq8L591CrcGBWVp7cz3GHljB
        5Bau+QKBgQCygovC85S56aSyFvau84HPYY5EEgrMJ4JtNLqaqHeHtVRyWztRJjn5
        vlSyB26ZZ1uTZ1PvRUfUnLymWVshxFV12Tz371ql04DXMyeAcLYbOvTJu3tWad8V
        A5vU9c2PUVTs9i2Erf46ZDjNhqqf2eN534puIoLSqU7H+DUxHXDl9g==
        -----END RSA PRIVATE KEY-----
      owner: root:root
      path: /etc/ssh/vgcn.key
      permission: '0644'
    - content: |
        CONDOR_HOST = localhost
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
      path: /etc/ssh/ssh_config
      permissions: '0644'

    runcmd:
      - [mv, /etc/ssh/vgcn.key, /home/centos/.ssh/id_rsa]
      - chmod 0600 /home/centos/.ssh/id_rsa
      - [chown, centos.centos, /home/centos/.ssh/id_rsa]
  EOF
}
