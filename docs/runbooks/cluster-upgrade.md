# Runbook: GKE Cluster Upgrade

## Goal

Safely upgrade GKE clusters while preserving workload availability and platform governance.

## Pre-Checks

- Confirm current release channel and target version in Google Cloud.
- Review node pool disruption budgets and critical workload PodDisruptionBudgets.
- Confirm no active incidents or freeze windows.
- Run `terraform plan` for the target environment.
- Check Fleet membership and Policy Controller health.

## Procedure

1. Upgrade non-production first and observe for at least one business day.
2. Review API server, scheduler, controller manager, and node readiness metrics.
3. Promote the same Terraform change into production.
4. Upgrade system node pools before tenant node pools.
5. Keep surge upgrades enabled with `max_unavailable = 0`.
6. Monitor workload restarts, pending pods, and node readiness.

## Rollback

GKE control plane downgrades are limited. Treat rollback as workload migration or node pool replacement:

- Create a replacement node pool on the previous known-good version if supported.
- Cordon and drain affected node pools gradually.
- Revert Terraform changes that introduced incompatible configuration.

## Success Criteria

- All nodes are Ready.
- Critical workloads meet availability SLOs.
- No sustained API server or controller manager errors.
- Policy Controller and Config Sync are healthy.
