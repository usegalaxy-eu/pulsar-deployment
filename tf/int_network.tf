resource "oci_core_vcn" "internal" {
  compartment_id = var.oracle_vars.compartment_id
  display_name   = var.private_network["name"]
  cidr_block     = var.private_network["cidr4"]
  dns_label      = replace(var.private_network["name"], "-", "")
}

resource "oci_core_subnet" "internal" {
  compartment_id             = var.oracle_vars.compartment_id
  vcn_id                     = oci_core_vcn.internal.id
  display_name               = var.private_network["subnet_name"]
  cidr_block                 = var.private_network["cidr4"]
  dns_label                  = replace(var.private_network["subnet_name"], "-", "")
  prohibit_public_ip_on_vnic = false  # Equivalent to enabling DHCP
  route_table_id             = oci_core_route_table.route_table_1.id
}

resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = var.oracle_vars.compartment_id
  vcn_id         = oci_core_vcn.internal.id
  display_name   = "${var.name_prefix}internet-gateway"
  enabled        = true
}

resource "oci_core_service_gateway" "service_gateway" {
  compartment_id = var.oracle_vars.compartment_id
  vcn_id         = oci_core_vcn.internal.id
  display_name   = "${var.name_prefix}service-gateway"
  
  services {
    service_id = data.oci_core_services.public_network.services[0].id
  }
}

resource "oci_core_route_table" "route_table_1" {
  compartment_id = var.oracle_vars.compartment_id
  vcn_id         = oci_core_vcn.internal.id
  display_name   = "${var.name_prefix}route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
  
  route_rules {
    destination       = data.oci_core_services.public_network.services[0].cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.service_gateway.id
  }
}