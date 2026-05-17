resource "google_gke_hub_feature" "policy_controller" {
  count = var.enable_policy_controller ? 1 : 0

  project  = var.project_id
  name     = "policycontroller"
  location = "global"
}

resource "google_gke_hub_feature" "config_management" {
  count = var.enable_config_sync ? 1 : 0

  project  = var.project_id
  name     = "configmanagement"
  location = "global"
}

resource "google_gke_hub_membership" "this" {
  for_each = var.memberships

  project       = var.project_id
  membership_id = each.key
  location      = "global"
  labels        = each.value.labels

  endpoint {
    gke_cluster {
      resource_link = coalesce(
        each.value.cluster_self_link,
        "//container.googleapis.com/projects/${var.project_id}/locations/${each.value.cluster_location}/clusters/${each.value.cluster_name}"
      )
    }
  }
}

resource "google_gke_hub_feature_membership" "policy_controller" {
  for_each = var.enable_policy_controller ? var.memberships : {}

  project    = var.project_id
  location   = "global"
  feature    = google_gke_hub_feature.policy_controller[0].name
  membership = google_gke_hub_membership.this[each.key].membership_id

  policycontroller {
    policy_controller_hub_config {
      install_spec              = "INSTALL_SPEC_ENABLED"
      audit_interval_seconds    = 60
      exemptable_namespaces     = ["kube-system", "gke-system", "config-management-system"]
      log_denies_enabled        = true
      mutation_enabled          = true
      referential_rules_enabled = true
    }
  }
}
