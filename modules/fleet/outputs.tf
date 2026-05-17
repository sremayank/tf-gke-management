output "membership_names" {
  description = "Fleet membership names."
  value       = keys(google_gke_hub_membership.this)
}

output "policy_controller_enabled" {
  description = "Whether Policy Controller is enabled."
  value       = var.enable_policy_controller
}
