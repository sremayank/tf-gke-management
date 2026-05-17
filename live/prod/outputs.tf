output "cluster_names" {
  description = "Production cluster names."
  value = {
    primary   = module.primary_cluster.name
    secondary = module.secondary_cluster.name
  }
}

output "fleet_memberships" {
  description = "Fleet memberships created for production."
  value       = module.fleet.membership_names
}

output "workload_identity_service_accounts" {
  description = "Platform workload Google service accounts."
  value       = module.workload_identity.service_accounts
}
