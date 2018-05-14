resource "openstack_compute_instance_v2" "test-flock-manager" {
	name            = "test-flock-manager"
	flavor_name     = "m1.medium"
	image_name      = "${var.image}"
	key_pair        = "${var.key_pair}"
	security_groups = "${var.secgroups}"
	network         = "${var.network}"
	user_data = "${file("conf/fm.yml")}"
}

resource "openstack_compute_instance_v2" "test-cm" {
	name            = "test-cm-1"
	flavor_name     = "m1.medium"
	image_name      = "${var.image}"
	key_pair        = "${var.key_pair}"
	security_groups = "${var.secgroups}"
	network         = "${var.network}"
	user_data = "${file("conf/cm-0.yml")}"
}

resource "openstack_compute_instance_v2" "test-exec-1" {
	count           = 2
	name            = "test-exec-1-${count.index}"
	flavor_name     = "m1.medium"
	image_name      = "${var.image}"
	key_pair        = "${var.key_pair}"
	security_groups = "${var.secgroups}"
	network         = "${var.network}"
	user_data = "${file("conf/exec-0.yml")}"
}


resource "openstack_compute_instance_v2" "test-cm-alt" {
	name            = "test-cm-2"
	flavor_name     = "m1.medium"
	image_name      = "${var.image}"
	key_pair        = "${var.key_pair}"
	security_groups = "${var.secgroups}"
	network         = "${var.network}"
	user_data = "${file("conf/cm-1.yml")}"
}

resource "openstack_compute_instance_v2" "test-exec-2" {
	count           = 2
	name            = "test-exec-2-${count.index}"
	flavor_name     = "m1.medium"
	image_name      = "${var.image}"
	key_pair        = "${var.key_pair}"
	security_groups = "${var.secgroups}"
	network         = "${var.network}"
	user_data       = "${file("conf/exec-1.yml")}"
}
