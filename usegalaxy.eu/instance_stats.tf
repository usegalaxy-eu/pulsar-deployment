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

resource "openstack_blockstorage_volume_v3" "stats-data" {
  name        = "stats_data"
  description = "Data volume for Grafana"
  size        = 2
}

resource "openstack_blockstorage_volume_attach_v3" "stats_va" {
  volume_id  = "${openstack_blockstorage_volume_v3.stats-data.id}"
  device     = "/dev/vdx"
  host_name  = "stats.usegalaxy.eu"
  ip_address = "${openstack_compute_instance_v2.stats-usegalaxy.access_ip_v4}"
}

# CNAME since everything should go through proxy
resource "aws_route53_record" "stats-usegalaxy" {
  zone_id = "${var.zone_galaxyproject_eu}"
  name    = "stats.galaxyproject.eu"
  type    = "CNAME"
  ttl     = "7200"
  records = ["proxy.galaxyproject.eu"]
}

# But an internal record to permit SSHing until we find a nice solution for that.
resource "aws_route53_record" "stats-usegalaxy-internal" {
  zone_id = "${var.zone_galaxyproject_eu}"
  name    = "stats.internal.galaxyproject.eu"
  type    = "A"
  ttl     = "7200"
  records = ["${openstack_compute_instance_v2.stats-usegalaxy.access_ip_v4}"]
}
