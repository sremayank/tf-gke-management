variable "project_id" {
  description = "Google Cloud project."
  type        = string
}

variable "bindings" {
  description = "Kubernetes service account to Google service account bindings."
  type = map(object({
    namespace                  = string
    kubernetes_service_account = string
    google_service_account_id  = string
    display_name               = optional(string)
    roles                      = list(string)
  }))
}
