resource "openstack_compute_instance_v2" "build-usegalaxy" {
  name            = "build.usegalaxy.eu"
  image_name      = "CentOS 7"
  flavor_name     = "m1.large"
  key_pair        = "cloud2"
  security_groups = ["egress", "ufr-ssh", "public-web"]

  network {
    name = "public"
  }
}

# CNAME since everything should go through proxy
resource "aws_route53_record" "build-usegalaxy" {
  zone_id = "${var.zone_galaxyproject_eu}"
  name    = "build.galaxyproject.eu"
  type    = "CNAME"
  ttl     = "7200"
  records = ["proxy.usegalaxy.eu"]
}

# But an internal record to permit SSHing until we find a nice solution for that.
resource "aws_route53_record" "build-usegalaxy-internal" {
  zone_id = "${var.zone_galaxyproject_eu}"
  name    = "build.internal.galaxyproject.eu"
  type    = "A"
  ttl     = "7200"
  records = ["${openstack_compute_instance_v2.build-usegalaxy.access_ip_v4}"]
}
