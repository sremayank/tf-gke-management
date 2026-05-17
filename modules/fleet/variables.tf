variable "project_id" {
  description = "Fleet host project."
  type        = string
}

variable "memberships" {
  description = "Fleet memberships keyed by membership name."
  type = map(object({
    cluster_name      = string
    cluster_location  = string
    cluster_self_link = optional(string)
    labels            = optional(map(string), {})
  }))
}

variable "enable_policy_controller" {
  description = "Enable Policy Controller for the fleet."
  type        = bool
  default     = true
}

variable "enable_config_sync" {
  description = "Enable Fleet Config Management feature."
  type        = bool
  default     = true
}
