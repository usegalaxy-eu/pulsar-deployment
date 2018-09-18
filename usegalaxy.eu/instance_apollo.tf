resource "openstack_compute_instance_v2" "apollo-usegalaxy" {
  name            = "apollo.internal.usegalaxy.eu"
  image_name      = "${var.centos_image}"
  flavor_name     = "m1.large"
  key_pair        = "cloud2"
  security_groups = ["egress", "ufr-ssh", "public-web"]

  network {
    name = "bioinf"
  }
}

# CNAME since everything should go through proxy
resource "aws_route53_record" "apollo-usegalaxy" {
  zone_id = "${var.zone_usegalaxy_eu}"
  name    = "apollo.usegalaxy.eu"
  type    = "CNAME"
  ttl     = "7200"
  records = ["proxy.galaxyproject.eu"]
}

# But an internal record to permit SSHing until we find a nice solution for that.
resource "aws_route53_record" "apollo-usegalaxy-internal" {
  zone_id = "${var.zone_usegalaxy_eu}"
  name    = "apollo.internal.usegalaxy.eu"
  type    = "A"
  ttl     = "7200"
  records = ["${openstack_compute_instance_v2.apollo-usegalaxy.access_ip_v4}"]
}
