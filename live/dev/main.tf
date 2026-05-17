locals {
  labels = {
    environment = "dev"
    platform    = "gke-management"
    managed_by  = "terraform"
  }
}

module "network" {
  source = "../../modules/network"

  project_id             = var.project_id
  name                   = "dev-gke-platform"
  region                 = var.region
  authorized_admin_cidrs = var.authorized_admin_cidrs

  subnets = {
    "dev-gke-primary" = {
      cidr                    = "10.20.0.0/20"
      pods_secondary_name     = "dev-gke-primary-pods"
      pods_secondary_cidr     = "10.24.0.0/14"
      services_secondary_name = "dev-gke-primary-services"
      services_secondary_cidr = "10.28.0.0/20"
    }
  }
}

module "primary_cluster" {
  source = "../../modules/gke-cluster"

  project_id                    = var.project_id
  name                          = "dev-platform-primary"
  location                      = var.region
  network                       = module.network.network_id
  subnetwork                    = module.network.subnets["dev-gke-primary"].self_link
  pods_secondary_range_name     = module.network.subnets["dev-gke-primary"].pods_secondary_name
  services_secondary_range_name = module.network.subnets["dev-gke-primary"].services_secondary_name
  master_ipv4_cidr_block        = "172.16.0.0/28"
  release_channel               = "REGULAR"
  master_authorized_networks = [
    for cidr in var.authorized_admin_cidrs : {
      cidr_block   = cidr
      display_name = "platform-admin"
    }
  ]
  labels = local.labels

  node_pools = {
    "platform-system" = {
      machine_type = "e2-standard-4"
      min_count    = 1
      max_count    = 3
      labels = {
        workload = "system"
      }
    }
    "workload-spot" = {
      machine_type = "e2-standard-4"
      min_count    = 0
      max_count    = 5
      spot         = true
      labels = {
        workload = "stateless"
      }
      taints = [{
        key    = "capacity"
        value  = "spot"
        effect = "NO_SCHEDULE"
      }]
    }
  }
}

module "workload_identity" {
  source = "../../modules/workload-identity"

  project_id = var.project_id
  bindings = {
    external_dns = {
      namespace                  = "platform-dns"
      kubernetes_service_account = "external-dns"
      google_service_account_id  = "dev-external-dns"
      roles                      = ["roles/dns.admin"]
    }
    cert_manager = {
      namespace                  = "cert-manager"
      kubernetes_service_account = "cert-manager"
      google_service_account_id  = "dev-cert-manager"
      roles                      = ["roles/dns.admin"]
    }
  }
}

module "fleet" {
  source = "../../modules/fleet"

  project_id = var.project_id
  memberships = {
    "dev-platform-primary" = {
      cluster_name     = module.primary_cluster.name
      cluster_location = module.primary_cluster.location
      labels           = local.labels
    }
  }
}

module "observability" {
  source = "../../modules/observability"

  project_id            = var.project_id
  cluster_names         = [module.primary_cluster.name]
  notification_channels = var.notification_channels
  labels                = local.labels
}
