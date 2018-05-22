resource "openstack_compute_instance_v2" "vault-server" {
  name        = "vault.usegalaxy.eu"
  flavor_name = "m1.tiny"
  image_name  = "CentOS Server 7 RAW"
  key_pair    = "${var.key_pair}"

  security_groups = [
    "ingress-public",
    "egress-public",
  ]

  network = [
    {
      name = "public2"
    },
  ]

  #  provisioner "remote-exec" {
  #    inline = [
  #      "git clone https://github.com/usegalaxy-eu/infrastructure-playbook /tmp/playbook",
  #      "ansible-playbook /tmp/playbook/vault.yml --connection=local --inventory=localhost",
  #    ]
  #
  #    connection {
  #      user        = "centos"
  #      private_key = "${file(".ssh_key")}"
  #    }
  #  }
}

resource "aws_route53_record" "vault-route53" {
  zone_id = "Z3BOXJYLR7ZV7D"
  name    = "vault.usegalaxy.eu"
  type    = "A"
  ttl     = "300"
  records = ["${openstack_compute_instance_v2.vault-server.access_ip_v4}"]
}
