terraform {
  backend "gcs" {
    bucket = "replace-me-dev-tfstate"
    prefix = "gke-management/dev"
  }
}
