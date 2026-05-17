resource "google_service_account" "this" {
  for_each = var.bindings

  project      = var.project_id
  account_id   = each.value.google_service_account_id
  display_name = coalesce(each.value.display_name, "Workload Identity for ${each.value.namespace}/${each.value.kubernetes_service_account}")
}

resource "google_service_account_iam_member" "workload_identity_user" {
  for_each = var.bindings

  service_account_id = google_service_account.this[each.key].name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${each.value.namespace}/${each.value.kubernetes_service_account}]"
}

resource "google_project_iam_member" "roles" {
  for_each = {
    for binding in flatten([
      for name, config in var.bindings : [
        for role in config.roles : {
          key  = "${name}:${role}"
          sa   = name
          role = role
        }
      ]
    ]) : binding.key => binding
  }

  project = var.project_id
  role    = each.value.role
  member  = google_service_account.this[each.value.sa].member
}
