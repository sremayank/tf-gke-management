# Runbook: Onboard A New Cluster

## Inputs

- Project ID
- Region
- Cluster name
- Primary, pod, and service CIDRs
- Admin CIDRs
- Required workload identities
- Expected node pool profiles

## Steps

1. Add subnet capacity to the environment `module "network"` block.
2. Add a `module "gke_cluster"` block using `modules/gke-cluster`.
3. Register the cluster in the environment `module "fleet"` membership map.
4. Add required Workload Identity bindings.
5. Add the cluster to the observability module.
6. Run formatting, validation, linting, and policy checks.
7. Open a pull request with the Terraform plan attached.

## Acceptance Criteria

- Cluster is private and VPC-native.
- Workload Identity is enabled.
- Fleet membership exists.
- Policy Controller is enabled.
- Managed Prometheus is enabled.
- Node pools use shielded nodes and automatic repair.
