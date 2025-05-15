# Central Manager Security Groups

# Allow any incoming connection from private network
resource "oci_core_network_security_group" "cm_ingress_private" {
  compartment_id = var.oracle_vars.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = var.secgroups_cm.in_pvt_name
}

resource "oci_core_network_security_group_security_rule" "cm_ingress_private_rule" {
  network_security_group_id = oci_core_network_security_group.cm_ingress_private.id
  direction                 = "INGRESS"
  protocol                  = "all"
  
  source_type               = "NETWORK_SECURITY_GROUP"
  source                    = oci_core_network_security_group.cm_ingress_private.id
}

# Allow any outgoing connection
resource "oci_core_network_security_group" "cm_egress_public" {
  compartment_id = var.oracle_vars.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = var.secgroups_cm.en_pub_name
}

resource "oci_core_network_security_group_security_rule" "cm_egress_public_rule" {
  network_security_group_id = oci_core_network_security_group.cm_egress_public.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination_type          = "CIDR_BLOCK"
  destination               = "0.0.0.0/0"
}

# Allow SSH connections from anywhere
resource "oci_core_network_security_group" "public_ssh" {
  compartment_id = var.oracle_vars.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = var.secgroups_cm.ssh_name
}

resource "oci_core_network_security_group_security_rule" "public_ssh_rule" {
  network_security_group_id = oci_core_network_security_group.public_ssh.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source_type               = "CIDR_BLOCK"
  source                    = "0.0.0.0/0"
  
  tcp_options {
    destination_port_range {
      min = var.ssh-port
      max = var.ssh-port
    }
  }
}

# Other Nodes Security groups

# Allow any incoming connection from private network, should open at least nfs, 9618 for HTCondor and 22 for ssh
resource "oci_core_network_security_group" "ingress_private" {
  compartment_id = var.oracle_vars.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = var.secgroups.in_pvt_name
}

resource "oci_core_network_security_group_security_rule" "ingress_private_rule" {
  network_security_group_id = oci_core_network_security_group.ingress_private.id
  direction                 = "INGRESS"
  protocol                  = "all"
  
  source_type               = "NETWORK_SECURITY_GROUP"
  source                    = oci_core_network_security_group.ingress_private.id
}

# Allow any outgoing connection
resource "oci_core_network_security_group" "egress_public" {
  compartment_id = var.oracle_vars.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = var.secgroups.en_pub_name
}

resource "oci_core_network_security_group_security_rule" "egress_public_rule" {
  network_security_group_id = oci_core_network_security_group.egress_public.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination_type          = "CIDR_BLOCK"
  destination               = "0.0.0.0/0"
}

# Communication between the internal nodes and the central manager groups
resource "oci_core_network_security_group_security_rule" "ingress_private_from_cm_rule" {
  network_security_group_id = oci_core_network_security_group.ingress_private.id
  direction                 = "INGRESS"
  protocol                  = "all"
  
  source_type               = "NETWORK_SECURITY_GROUP"
  source                    = oci_core_network_security_group.cm_ingress_private.id
}

resource "oci_core_network_security_group_security_rule" "cm_ingress_private_from_worker_rule" {
  network_security_group_id = oci_core_network_security_group.cm_ingress_private.id
  direction                 = "INGRESS"
  protocol                  = "all"
  
  source_type               = "NETWORK_SECURITY_GROUP"
  source                    = oci_core_network_security_group.ingress_private.id
}
