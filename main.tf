resource "openstack_compute_instance_v2" "test-cm" {
	name            = "test-cm"
	flavor_name     = "m1.medium"
	image_name      = "test-vgcn-general"
	key_pair        = "cloud2"
	security_groups = [
		"public-web",
		"public-ssh",
		"public-ping",
		"Public",
		"egress",
	]
	network         = [
		{ name = "galaxy-net" },
	],
	user_data = "${file("conf/cm.yml")}"
}

resource "aws_route53_record" "cm" {
	zone_id = "Z3BOXJYLR7ZV7D"
	name    = "manager.condor.usegalaxy.eu"
	type    = "A"
	ttl     = "300"
	records = ["${openstack_compute_instance_v2.test-cm.access_ip_v4}"]
}

resource "openstack_compute_instance_v2" "test-exec-1" {
	name            = "test-exec-1"
	flavor_name     = "m1.medium"
	image_name      = "test-vgcn-general"
	key_pair        = "cloud2"
	security_groups = [
		"public-web",
		"public-ssh",
		"public-ping",
		"Public",
		"egress",
	]
	network         = [
		{ name = "galaxy-net" },
	],
	user_data = "${file("conf/exec.yml")}"
}

resource "aws_route53_record" "test-exec-1" {
	zone_id = "Z3BOXJYLR7ZV7D"
	name    = "exec-01.condor.usegalaxy.eu"
	type    = "A"
	ttl     = "300"
	records = ["${openstack_compute_instance_v2.test-exec-1.access_ip_v4}"]
}
