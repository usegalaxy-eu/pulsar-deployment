data "oci_core_services" "all_oci_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

resource "oci_core_service_gateway" "service_gateway" {
  compartment_id = var.oracle_vars.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.name_prefix}service-gateway"
  
  services {
    service_id = data.oci_core_services.all_oci_services.services[0].id
  }
}