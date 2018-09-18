resource "openstack_compute_instance_v2" "vgcn-cm" {
  name            = "manager.vgcn.usegalaxy.eu"
  image_name      = "vggp-v30-j70-bb213b59aad0-pulsar"
  flavor_name     = "m1.small"
  key_pair        = "cloud2"
  security_groups = ["egress", "ufr-ssh", "public-web"]

  network {
    name = "bioinf"
  }

  user_data = "${file("conf/cm.yml")}"
}

resource "aws_route53_record" "vgcn-cm" {
  zone_id = "${var.zone_usegalaxy_eu}"
  name    = "manager.vgcn.usegalaxy.eu"
  type    = "A"
  ttl     = "300"
  records = ["${openstack_compute_instance_v2.vgcn-cm.access_ip_v4}"]
}
