variable "project_id" {
  description = "Production Google Cloud project."
  type        = string
}

variable "region" {
  description = "Primary region."
  type        = string
  default     = "europe-west2"
}

variable "dr_region" {
  description = "Secondary region for resilience."
  type        = string
  default     = "europe-west1"
}

variable "authorized_admin_cidrs" {
  description = "CIDRs allowed to access administrative endpoints."
  type        = list(string)
}

variable "notification_channels" {
  description = "Existing Cloud Monitoring notification channel IDs."
  type        = list(string)
  default     = []
}

variable "rbac_security_group" {
  description = "Google Group used as the root for Google Groups for GKE RBAC."
  type        = string
  default     = "gke-security-groups@example.com"
}
