resource "google_compute_network" "this" {
  project                 = var.project_id
  name                    = var.name
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
  description             = "Shared VPC foundation for managed GKE clusters."
}

locals {
  subnet_regions = toset([
    for subnet in var.subnets : coalesce(subnet.region, var.region)
  ])
}

resource "google_compute_subnetwork" "this" {
  for_each = var.subnets

  project                  = var.project_id
  name                     = each.key
  region                   = coalesce(each.value.region, var.region)
  network                  = google_compute_network.this.id
  ip_cidr_range            = each.value.cidr
  private_ip_google_access = each.value.private_google_access
  purpose                  = "PRIVATE"

  secondary_ip_range {
    range_name    = each.value.pods_secondary_name
    ip_cidr_range = each.value.pods_secondary_cidr
  }

  secondary_ip_range {
    range_name    = each.value.services_secondary_name
    ip_cidr_range = each.value.services_secondary_cidr
  }

  dynamic "log_config" {
    for_each = each.value.flow_logs_enabled ? [1] : []

    content {
      aggregation_interval = "INTERVAL_10_MIN"
      flow_sampling        = 0.5
      metadata             = "INCLUDE_ALL_METADATA"
    }
  }
}

resource "google_compute_router" "this" {
  for_each = local.subnet_regions

  project = var.project_id
  name    = "${var.name}-${each.key}-router"
  region  = each.key
  network = google_compute_network.this.id
}

resource "google_compute_router_nat" "this" {
  for_each = local.subnet_regions

  project                            = var.project_id
  name                               = "${var.name}-${each.key}-nat"
  router                             = google_compute_router.this[each.key].name
  region                             = each.key
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  min_ports_per_vm                   = 128

  dynamic "subnetwork" {
    for_each = {
      for name, subnet in google_compute_subnetwork.this : name => subnet
      if subnet.region == each.key
    }

    content {
      name                    = subnetwork.value.id
      source_ip_ranges_to_nat = ["PRIMARY_IP_RANGE", "LIST_OF_SECONDARY_IP_RANGES"]
      secondary_ip_range_names = [
        for range in subnetwork.value.secondary_ip_range : range.range_name
      ]
    }
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_firewall" "deny_ingress" {
  project     = var.project_id
  name        = "${var.name}-deny-ingress"
  network     = google_compute_network.this.name
  description = "Default deny ingress baseline for the GKE shared network."
  direction   = "INGRESS"
  priority    = 65534

  deny {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_admin" {
  count = length(var.authorized_admin_cidrs) > 0 ? 1 : 0

  project     = var.project_id
  name        = "${var.name}-allow-admin"
  network     = google_compute_network.this.name
  description = "Restricted administrative access from approved corporate CIDRs."
  direction   = "INGRESS"
  priority    = 1000

  allow {
    protocol = "tcp"
    ports    = ["22", "443"]
  }

  source_ranges = var.authorized_admin_cidrs
  target_tags   = ["platform-admin"]
}
