variable "project_id" {
  description = "Google Cloud project."
  type        = string
}

variable "notification_channels" {
  description = "Existing Cloud Monitoring notification channel IDs."
  type        = list(string)
  default     = []
}

variable "cluster_names" {
  description = "Cluster names to monitor."
  type        = list(string)
}

variable "labels" {
  description = "Labels applied to supported resources."
  type        = map(string)
  default     = {}
}
