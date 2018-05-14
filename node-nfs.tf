resource "openstack_compute_instance_v2" "nfs-server" {
  name            = "test-nfs"
  flavor_name     = "m1.medium"
  image_name      = "${var.image}"
  key_pair        = "${var.key_pair}"
  security_groups = "${var.secgroups}"
  network         = "${var.network}"
  user_data       = "${file("conf/nfs.yml")}"
}

resource "aws_route53_record" "nfs-server" {
  zone_id = "Z3BOXJYLR7ZV7D"
  name    = "nfs.condor.usegalaxy.eu"
  type    = "A"
  ttl     = "300"
  records = ["${openstack_compute_instance_v2.nfs-server.access_ip_v4}"]
}
