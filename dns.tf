resource "aws_route53_record" "fm" {
	zone_id = "Z3BOXJYLR7ZV7D"
	name    = "flock.condor.usegalaxy.eu"
	type    = "A"
	ttl     = "300"
	records = ["${openstack_compute_instance_v2.test-flock-manager.access_ip_v4}"]
}

resource "aws_route53_record" "cm" {
	zone_id = "Z3BOXJYLR7ZV7D"
	name    = "manager01.condor.usegalaxy.eu"
	type    = "A"
	ttl     = "300"
	records = ["${openstack_compute_instance_v2.test-cm.access_ip_v4}"]
}

resource "aws_route53_record" "cm-alt" {
	zone_id = "Z3BOXJYLR7ZV7D"
	name    = "manager02.condor.usegalaxy.eu"
	type    = "A"
	ttl     = "300"
	records = ["${openstack_compute_instance_v2.test-cm-alt.access_ip_v4}"]
}
