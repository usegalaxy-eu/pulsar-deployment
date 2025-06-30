output "node_name" {
  value       = oci_core_instance.central_manager.display_name
  description = "The name of the central manager node"
}

output "cm_ip_v4_internal" {
  value       = oci_core_instance.central_manager.private_ip
  description = "The private/internal IPv4 address of the central manager"
}

output "cm_ip_v4_public" {
  value       = oci_core_instance.central_manager.public_ip
  description = "The public IPv4 address of the central manager"
}
