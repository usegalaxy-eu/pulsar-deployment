resource "openstack_compute_instance_v2" "jenkins-workers" {
  name            = "worker-${count.index}.build.usegalaxy.eu"
  image_name      = "jenkins-worker-j18-b3e81a5bbb75-master"
  flavor_name     = "m1.xlarge"
  key_pair        = "build-usegalaxy-eu"
  security_groups = ["egress", "ufr-ssh", "public-ping"]
  count           = 2

  network {
    name = "public"
  }
}
