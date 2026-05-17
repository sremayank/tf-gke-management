variable "project_id" {
  description = "Google Cloud project that owns the network."
  type        = string
}

variable "name" {
  description = "Network name."
  type        = string
}

variable "region" {
  description = "Region for subnets and Cloud Router."
  type        = string
}

variable "subnets" {
  description = "Subnet definitions, including GKE secondary ranges."
  type = map(object({
    cidr                    = string
    region                  = optional(string)
    pods_secondary_name     = string
    pods_secondary_cidr     = string
    services_secondary_name = string
    services_secondary_cidr = string
    private_google_access   = optional(bool, true)
    flow_logs_enabled       = optional(bool, true)
  }))
}

variable "authorized_admin_cidrs" {
  description = "CIDRs allowed to reach approved administrative endpoints."
  type        = list(string)
  default     = []
}

variable "labels" {
  description = "Labels applied to supported resources."
  type        = map(string)
  default     = {}
}
