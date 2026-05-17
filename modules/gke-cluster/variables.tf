variable "project_id" {
  description = "Google Cloud project that hosts the cluster."
  type        = string
}

variable "name" {
  description = "GKE cluster name."
  type        = string
}

variable "location" {
  description = "Regional or zonal cluster location."
  type        = string
}

variable "network" {
  description = "VPC network self link."
  type        = string
}

variable "subnetwork" {
  description = "Subnet self link."
  type        = string
}

variable "pods_secondary_range_name" {
  description = "Secondary range used for pod IPs."
  type        = string
}

variable "services_secondary_range_name" {
  description = "Secondary range used for service IPs."
  type        = string
}

variable "master_ipv4_cidr_block" {
  description = "Private control-plane CIDR."
  type        = string
}

variable "master_authorized_networks" {
  description = "CIDR blocks allowed to reach the public control-plane endpoint if enabled."
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

variable "release_channel" {
  description = "GKE release channel."
  type        = string
  default     = "REGULAR"
}

variable "rbac_security_group" {
  description = "Google Group used as the root for Google Groups for GKE RBAC."
  type        = string
}

variable "node_pools" {
  description = "Managed node pools."
  type = map(object({
    machine_type    = string
    min_count       = number
    max_count       = number
    disk_size_gb    = optional(number, 100)
    disk_type       = optional(string, "pd-balanced")
    spot            = optional(bool, false)
    service_account = optional(string)
    labels          = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
  }))
}

variable "labels" {
  description = "Labels applied to supported resources."
  type        = map(string)
  default     = {}
}
