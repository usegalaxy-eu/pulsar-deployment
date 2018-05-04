resource "openstack_compute_instance_v2" "test-flock-manager" {
	name            = "test-flock-manager"
	flavor_name     = "m1.medium"
	image_name      = "test-vgcn-general"
	key_pair        = "cloud2"
	security_groups = [
		"ingress-public",
		"egress",
	]
	network         = [
		{ name = "galaxy-net" },
	],
	user_data = "${file("conf/fm.yml")}"
}

resource "aws_route53_record" "fm" {
	zone_id = "Z3BOXJYLR7ZV7D"
	name    = "flock.condor.usegalaxy.eu"
	type    = "A"
	ttl     = "300"
	records = ["${openstack_compute_instance_v2.test-flock-manager.access_ip_v4}"]
}

resource "openstack_compute_instance_v2" "test-cm" {
	name            = "test-cm"
	flavor_name     = "m1.medium"
	image_name      = "test-vgcn-general"
	key_pair        = "cloud2"
	security_groups = [
		"ingress-public",
		"egress",
	]
	network         = [
		{ name = "galaxy-net" },
	],
	user_data = "${file("conf/cm-0.yml")}"
}

resource "aws_route53_record" "cm" {
	zone_id = "Z3BOXJYLR7ZV7D"
	name    = "manager01.condor.usegalaxy.eu"
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
		"ingress-public",
		"egress",
	]
	network         = [
		{ name = "galaxy-net" },
	],
	user_data = "${file("conf/exec-0.yml")}"
}


resource "openstack_compute_instance_v2" "test-cm-alt" {
	name            = "test-cm-alt"
	flavor_name     = "m1.medium"
	image_name      = "test-vgcn-general"
	key_pair        = "cloud2"
	security_groups = [
		"ingress-public",
		"egress",
	]
	network         = [
		{ name = "galaxy-net" },
	],
	user_data = "${file("conf/cm-1.yml")}"
}

resource "aws_route53_record" "cm-alt" {
	zone_id = "Z3BOXJYLR7ZV7D"
	name    = "manager02.condor.usegalaxy.eu"
	type    = "A"
	ttl     = "300"
	records = ["${openstack_compute_instance_v2.test-cm-alt.access_ip_v4}"]
}

resource "openstack_compute_instance_v2" "test-exec-2" {
	name            = "test-exec-2"
	flavor_name     = "m1.medium"
	image_name      = "test-vgcn-general"
	key_pair        = "cloud2"
	security_groups = [
		"ingress-public",
		"egress",
	]
	network         = [
		{ name = "galaxy-net" },
	],
	user_data = "${file("conf/exec-1.yml")}"
}
