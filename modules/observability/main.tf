resource "google_monitoring_alert_policy" "node_not_ready" {
  for_each = toset(var.cluster_names)

  project      = var.project_id
  display_name = "GKE node readiness degraded - ${each.key}"
  combiner     = "OR"
  enabled      = true

  conditions {
    display_name = "Node not ready count is elevated"

    condition_threshold {
      filter          = "resource.type=\"k8s_node\" AND resource.labels.cluster_name=\"${each.key}\" AND metric.type=\"kubernetes.io/node/condition\" AND metric.labels.condition=\"Ready\" AND metric.labels.status=\"false\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  notification_channels = var.notification_channels

  documentation {
    content   = "One or more nodes in ${each.key} have reported NotReady for at least five minutes. Check recent upgrades, node pool health, and quota pressure."
    mime_type = "text/markdown"
  }

  user_labels = var.labels
}

resource "google_logging_metric" "control_plane_errors" {
  project = var.project_id
  name    = "gke_control_plane_error_count"
  filter  = "resource.type=\"k8s_cluster\" severity>=ERROR"

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
  }
}
