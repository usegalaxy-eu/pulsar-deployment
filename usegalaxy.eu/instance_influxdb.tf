resource "openstack_compute_instance_v2" "influxdb-usegalaxy" {
  name            = "influxdb.usegalaxy.eu"
  image_name      = "CentOS 7"
  flavor_name     = "m1.large"
  key_pair        = "cloud2"
  security_groups = ["egress", "ufr-ssh", "public-web"]

  network {
    name = "public"
  }
}

resource "openstack_blockstorage_volume_v3" "influxdb-data" {
  name        = "influxdb_data"
  description = "Data volume for InfluxDB"
  size        = 100
}

resource "openstack_blockstorage_volume_attach_v3" "influx_va" {
  volume_id  = "${openstack_blockstorage_volume_v3.influxdb-data.id}"
  device     = "/dev/vdx"
  host_name  = "influxdb.usegalaxy.eu"
  ip_address = "${openstack_compute_instance_v2.influxdb-usegalaxy.access_ip_v4}"
}

# CNAME since everything should go through proxy
resource "aws_route53_record" "influxdb-usegalaxy" {
  zone_id = "${var.zone_galaxyproject_eu}"
  name    = "influxdb.galaxyproject.eu"
  type    = "CNAME"
  ttl     = "7200"
  records = ["proxy.galaxyproject.eu"]
}

# But an internal record to permit SSHing until we find a nice solution for that.
resource "aws_route53_record" "influxdb-usegalaxy-internal" {
  zone_id = "${var.zone_galaxyproject_eu}"
  name    = "influxdb.internal.galaxyproject.eu"
  type    = "A"
  ttl     = "7200"
  records = ["${openstack_compute_instance_v2.influxdb-usegalaxy.access_ip_v4}"]
}
