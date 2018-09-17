resource "openstack_compute_instance_v2" "stats-usegalaxy" {
  name            = "stats.usegalaxy.eu"
  image_name      = "CentOS 7"
  flavor_name     = "m1.small"
  key_pair        = "cloud2"
  security_groups = ["egress", "ufr-ssh", "public-web"]

  network {
    name = "public"
  }
}

resource "aws_route53_record" "stats-usegalaxy" {
  zone_id = "Z3BOXJYLR7ZV7D"
  name    = "stats.new.usegalaxy.eu"
  type    = "A"
  ttl     = "300"
  records = ["${openstack_compute_instance_v2.stats-usegalaxy.access_ip_v4}"]
}
