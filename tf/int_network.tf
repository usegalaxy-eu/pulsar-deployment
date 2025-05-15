locals {
  base_cidr = var.main_vcn["cidr4"]
  subnets = {
    pvt_subnet = cidrsubnet(local.base_cidr, 8, 1),
    pub_subnet = cidrsubnet(local.base_cidr, 8, 2)
  }
}

resource "oci_core_vcn" "main" {
  compartment_id = var.oracle_vars.compartment_id
  display_name   = var.main_vcn["display_name"]
  cidr_block     = var.main_vcn["cidr4"]
  dns_label      = "mainvcn"
}

resource "oci_core_subnet" "private_subnet" {
  compartment_id             = var.oracle_vars.compartment_id
  vcn_id                     = oci_core_vcn.main.id
  display_name               = var.private_network["subnet_name"]
  cidr_block                 = local.subnets.pvt_subnet
  dns_label                  = "privsubnet"
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.combined_private_route.id
  security_list_ids          = [
                                oci_core_security_list.pvt_security_list.id
                               ]
}

resource "oci_core_subnet" "public_subnet" {
  compartment_id             = var.oracle_vars.compartment_id
  vcn_id                     = oci_core_vcn.main.id
  display_name               = var.public_network["subnet_name"]
  cidr_block                 = local.subnets.pub_subnet
  dns_label                  = "pubsubnet"
  prohibit_public_ip_on_vnic = false  # Equivalent to enabling DHCP
  route_table_id             = oci_core_route_table.internet_route_table.id
  security_list_ids          = [
                                oci_core_security_list.pub_security_list.id
                               ]
}

# IGW
resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = var.oracle_vars.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.name_prefix}internet-gateway"
  enabled        = true
}

# NAT gateway (provides internet to internal VMs without exposing them)
resource "oci_core_nat_gateway" "nat_gw" {
  compartment_id = var.oracle_vars.compartment_id
  vcn_id         =  oci_core_vcn.main.id
  display_name   = "NatGateway"
}

# Internet Gateway Route Table
resource "oci_core_route_table" "internet_route_table" {
  compartment_id = var.oracle_vars.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "internet-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
}

# OCI Services and NAT Gateway Route Table
resource "oci_core_route_table" "combined_private_route" {
  compartment_id = var.oracle_vars.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "combined-private-route"

  route_rules {
    description       = "Outbound to internet via NAT"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.nat_gw.id
  }

  route_rules {
    description       = "Access OCI Services"
    destination       = data.oci_core_services.all_oci_services.services[0].cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.service_gateway.id
  }
}

resource "oci_core_security_list" "pvt_security_list" {
  compartment_id = var.oracle_vars.compartment_id
  vcn_id         = oci_core_vcn.main.id

  ingress_security_rules {
    protocol = "all"
    source   = local.subnets.pub_subnet  # allow from public subnet
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}

resource "oci_core_security_list" "pub_security_list" {
  compartment_id = var.oracle_vars.compartment_id
  vcn_id         = oci_core_vcn.main.id

  ingress_security_rules {
    protocol = "all"
    source   = local.subnets.pvt_subnet  # allow from private subnet
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}
