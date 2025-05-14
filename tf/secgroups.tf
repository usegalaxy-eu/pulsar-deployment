
resource "oci_core_security_list" "cluster_security_list" {
  compartment_id = var.oracle_vars.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "pulsar_cluster_security"

  # Allow egress
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  # Allow internal communication (all protocols inside subnet)
  ingress_security_rules {
    protocol = "all"
    source   = local.subnets[1]
  }

  # Allow SSH from the internet (VMs without public IP won't be exposed)
  ingress_security_rules {
    protocol = "6"
    tcp_options {
      min = var.ssh-port
      max = var.ssh-port
    }
    source = "0.0.0.0/0"
  }

}
