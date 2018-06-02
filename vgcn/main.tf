resource "openstack_compute_instance_v2" "central-manager" {
  name            = "${var.prefix}central-manager${var.suffix}"
  flavor_name     = "m1.tiny"
  image_name      = "${var.image}"
  key_pair        = "${var.key_pair}"
  security_groups = "${var.secgroups}"
  network         = "${var.network}"
  user_data       = "${file("conf/cm.yml")}"
}

resource "openstack_compute_instance_v2" "m1.medium" {
  count           = 2
  name            = "${var.prefix}m1.medium${var.suffix}"
  flavor_name     = "m1.medium"
  image_name      = "${var.image}"
  key_pair        = "${var.key_pair}"
  security_groups = "${var.secgroups}"
  network         = "${var.network}"
  user_data       = "${file("conf/exec.yml")}"
}

resource "openstack_compute_instance_v2" "nfs-server" {
  name            = "${var.prefix}nfs${var.suffix}"
  flavor_name     = "m1.tiny"
  image_name      = "${var.image}"
  key_pair        = "${var.key_pair}"
  security_groups = "${var.secgroups}"
  network         = "${var.network}"
  user_data       = "${file("conf/nfs.yml")}"
}

resource "aws_route53_record" "nfs-server" {
  zone_id = "Z3BOXJYLR7ZV7D"
  name    = "nfs.vgcn.usegalaxy.eu"
  type    = "A"
  ttl     = "300"
  records = ["${openstack_compute_instance_v2.nfs-server.access_ip_v4}"]
}

resource "aws_route53_record" "cm" {
zone_id = "Z3BOXJYLR7ZV7D"
name    = "manager.vgcn.usegalaxy.eu"
type    = "A"
ttl     = "300"
records = ["${openstack_compute_instance_v2.test-cm.access_ip_v4}"]
}
