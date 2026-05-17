variable "project_id" {
  description = "Dev Google Cloud project."
  type        = string
}

variable "region" {
  description = "Primary region."
  type        = string
  default     = "europe-west2"
}

variable "authorized_admin_cidrs" {
  description = "CIDRs allowed to access administrative endpoints."
  type        = list(string)
  default     = []
}

variable "notification_channels" {
  description = "Existing Cloud Monitoring notification channel IDs."
  type        = list(string)
  default     = []
}
