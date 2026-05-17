locals {
  labels = {
    environment = "prod"
    platform    = "gke-management"
    managed_by  = "terraform"
  }
}

module "network" {
  source = "../../modules/network"

  project_id             = var.project_id
  name                   = "prod-gke-platform"
  region                 = var.region
  authorized_admin_cidrs = var.authorized_admin_cidrs

  subnets = {
    "prod-gke-primary" = {
      cidr                    = "10.40.0.0/20"
      pods_secondary_name     = "prod-gke-primary-pods"
      pods_secondary_cidr     = "10.44.0.0/14"
      services_secondary_name = "prod-gke-primary-services"
      services_secondary_cidr = "10.48.0.0/20"
    }
    "prod-gke-secondary" = {
      cidr                    = "10.50.0.0/20"
      region                  = var.dr_region
      pods_secondary_name     = "prod-gke-secondary-pods"
      pods_secondary_cidr     = "10.54.0.0/14"
      services_secondary_name = "prod-gke-secondary-services"
      services_secondary_cidr = "10.58.0.0/20"
    }
  }
}

module "primary_cluster" {
  source = "../../modules/gke-cluster"

  project_id                    = var.project_id
  name                          = "prod-platform-primary"
  location                      = var.region
  network                       = module.network.network_id
  subnetwork                    = module.network.subnets["prod-gke-primary"].self_link
  pods_secondary_range_name     = module.network.subnets["prod-gke-primary"].pods_secondary_name
  services_secondary_range_name = module.network.subnets["prod-gke-primary"].services_secondary_name
  master_ipv4_cidr_block        = "172.20.0.0/28"
  release_channel               = "STABLE"
  master_authorized_networks = [
    for cidr in var.authorized_admin_cidrs : {
      cidr_block   = cidr
      display_name = "platform-admin"
    }
  ]
  labels = local.labels

  node_pools = {
    "platform-system" = {
      machine_type = "e2-standard-8"
      min_count    = 3
      max_count    = 6
      labels = {
        workload = "system"
      }
    }
    "tenant-general" = {
      machine_type = "e2-standard-8"
      min_count    = 3
      max_count    = 12
      labels = {
        workload = "tenant"
      }
    }
  }
}

module "secondary_cluster" {
  source = "../../modules/gke-cluster"

  project_id                    = var.project_id
  name                          = "prod-platform-secondary"
  location                      = var.dr_region
  network                       = module.network.network_id
  subnetwork                    = module.network.subnets["prod-gke-secondary"].self_link
  pods_secondary_range_name     = module.network.subnets["prod-gke-secondary"].pods_secondary_name
  services_secondary_range_name = module.network.subnets["prod-gke-secondary"].services_secondary_name
  master_ipv4_cidr_block        = "172.20.0.16/28"
  release_channel               = "STABLE"
  master_authorized_networks = [
    for cidr in var.authorized_admin_cidrs : {
      cidr_block   = cidr
      display_name = "platform-admin"
    }
  ]
  labels = merge(local.labels, { role = "resilience" })

  node_pools = {
    "platform-system" = {
      machine_type = "e2-standard-8"
      min_count    = 2
      max_count    = 6
      labels = {
        workload = "system"
      }
    }
    "tenant-general" = {
      machine_type = "e2-standard-8"
      min_count    = 1
      max_count    = 10
      labels = {
        workload = "tenant"
      }
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
      google_service_account_id  = "prod-external-dns"
      roles                      = ["roles/dns.admin"]
    }
    cert_manager = {
      namespace                  = "cert-manager"
      kubernetes_service_account = "cert-manager"
      google_service_account_id  = "prod-cert-manager"
      roles                      = ["roles/dns.admin"]
    }
    external_secrets = {
      namespace                  = "external-secrets"
      kubernetes_service_account = "external-secrets"
      google_service_account_id  = "prod-external-secrets"
      roles                      = ["roles/secretmanager.secretAccessor"]
    }
  }
}

module "fleet" {
  source = "../../modules/fleet"

  project_id = var.project_id
  memberships = {
    "prod-platform-primary" = {
      cluster_name     = module.primary_cluster.name
      cluster_location = module.primary_cluster.location
      labels           = local.labels
    }
    "prod-platform-secondary" = {
      cluster_name     = module.secondary_cluster.name
      cluster_location = module.secondary_cluster.location
      labels           = merge(local.labels, { role = "resilience" })
    }
  }
}

module "observability" {
  source = "../../modules/observability"

  project_id = var.project_id
  cluster_names = [
    module.primary_cluster.name,
    module.secondary_cluster.name
  ]
  notification_channels = var.notification_channels
  labels                = local.labels
}
