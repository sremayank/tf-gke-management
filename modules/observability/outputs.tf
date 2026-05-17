output "node_not_ready_alerts" {
  description = "Alert policy names keyed by cluster name."
  value       = { for cluster, policy in google_monitoring_alert_policy.node_not_ready : cluster => policy.name }
}
