
resource "oci_core_network_security_group" "ingress_private" {
  compartment_id = var.oracle_vars.compartment_id
  vcn_id         = oci_core_vcn.internal.id
  display_name   = var.secgroups_cm[1]
  // description    = "[tf] Allow any incoming connection from private network"
}

resource "oci_core_network_security_group_security_rule" "ingress_private_4" {
  network_security_group_id = oci_core_network_security_group.ingress_private.id
  direction                 = "INGRESS"
  protocol                  = "all"
  source_type               = "NETWORK_SECURITY_GROUP"
  source                    = oci_core_network_security_group.ingress_private.id
}

# Allow any outgoing connection
resource "oci_core_network_security_group" "egress_public" {
  compartment_id = var.oracle_vars.compartment_id
  vcn_id         = oci_core_vcn.internal.id
  display_name   = var.secgroups_cm[2]
  // description    = "[tf] Allow any outgoing connection"
}

resource "oci_core_network_security_group_security_rule" "egress_public_4" {
  network_security_group_id = oci_core_network_security_group.egress_public.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination_type          = "CIDR_BLOCK"
  destination               = "0.0.0.0/0"
}

# Allow SSH connections from anywhere
resource "oci_core_network_security_group" "public_ssh" {
  compartment_id = var.oracle_vars.compartment_id
  vcn_id         = oci_core_vcn.internal.id
  display_name   = var.secgroups_cm[0]
  // description    = "[tf] Allow SSH connections from anywhere"
}

resource "oci_core_network_security_group_security_rule" "public_ssh_4" {
  network_security_group_id = oci_core_network_security_group.public_ssh.id
  direction                 = "INGRESS"
  protocol                  = "6"  # TCP protocol number
  source_type               = "CIDR_BLOCK"
  source                    = "0.0.0.0/0"
  
  tcp_options {
    destination_port_range {
      min = var.ssh-port
      max = var.ssh-port
    }
  }
}
