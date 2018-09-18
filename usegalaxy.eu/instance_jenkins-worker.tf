resource "openstack_compute_instance_v2" "jenkins-workers" {
  name            = "worker-${count.index}.build.internal.galaxyproject.eu"
  image_name      = "${var.jenkins_image}"
  flavor_name     = "m1.xlarge"
  key_pair        = "build-usegalaxy-eu"
  security_groups = ["egress", "ufr-ssh", "public-ping"]
  count           = 2

  network {
    name = "public"
  }
}

resource "aws_route53_record" "jenkins-workers-domain" {
  zone_id = "${var.zone_galaxyproject_eu}"
  name    = "worker-${count.index}.build.internal.galaxyproject.eu"
  type    = "A"
  ttl     = "7200"
  records = ["${openstack_compute_instance_v2.jenkins-workers.access_ip_v4}"]
}
