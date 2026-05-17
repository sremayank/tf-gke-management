output "network_id" {
  description = "Network self link."
  value       = google_compute_network.this.id
}

output "network_name" {
  description = "Network name."
  value       = google_compute_network.this.name
}

output "subnets" {
  description = "Subnet metadata keyed by subnet name."
  value = {
    for name, subnet in google_compute_subnetwork.this : name => {
      id                      = subnet.id
      self_link               = subnet.self_link
      region                  = subnet.region
      pods_secondary_name     = one([for range in subnet.secondary_ip_range : range.range_name if can(regex("pods", range.range_name))])
      services_secondary_name = one([for range in subnet.secondary_ip_range : range.range_name if can(regex("services", range.range_name))])
    }
  }
}
