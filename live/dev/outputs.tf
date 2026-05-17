output "cluster_name" {
  description = "Primary dev cluster name."
  value       = module.primary_cluster.name
}

output "node_service_account" {
  description = "Node service account email."
  value       = module.primary_cluster.node_service_account
}

output "fleet_memberships" {
  description = "Fleet memberships created for dev."
  value       = module.fleet.membership_names
}
