terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
      version = "7.0.0"
    }
  }
}

provider "oci" {
  tenancy_ocid         = var.oracle_vars.tenancy_ocid
  user_ocid            = var.oracle_vars.user_ocid
  fingerprint          = var.oracle_vars.fingerprint
  private_key_path     = var.oracle_vars.private_key_path
  region               = var.oracle_vars.region
}
