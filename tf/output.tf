output "node_name" {
  value       = oci_core_instance.central_manager.display_name
  description = "The name of the central manager node"
}

output "ip_v4_internal" {
  value       = oci_core_instance.central_manager.private_ip
  description = "The private/internal IPv4 address of the central manager"
}

output "ip_v4_public" {
  value       = oci_core_instance.central_manager.public_ip
  description = "The public IPv4 address of the central manager"
}

# Optional: Additional useful outputs

output "instance_state" {
  value       = oci_core_instance.central_manager.state
  description = "The current state of the instance"
}

output "availability_domain" {
  value       = oci_core_instance.central_manager.availability_domain
  description = "The availability domain where the instance is deployed"
}

output "instance_ocid" {
  value       = oci_core_instance.central_manager.id
  description = "The Oracle Cloud Identifier (OCID) of the instance"
}