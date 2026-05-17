terraform {
  backend "gcs" {
    bucket = "replace-me-prod-tfstate"
    prefix = "gke-management/prod"
  }
}
